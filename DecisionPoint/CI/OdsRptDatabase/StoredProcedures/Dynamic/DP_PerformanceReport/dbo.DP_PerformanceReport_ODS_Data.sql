IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.DP_PerformanceReport_Data') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.DP_PerformanceReport_Data
GO


CREATE PROCEDURE dbo.DP_PerformanceReport_Data (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@StartDate AS DATETIME,
@EndDate AS DATETIME,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@ReportId INT = 1,
@ReportType INT = 1,
@OdsCustomerId INT = 0)
AS
BEGIN

-- Setup Run parameters
-- DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@StartDate AS DATETIME = '20140901',@EndDate AS DATETIME = '20140930',@RunType INT = 1,@if_Date AS DATETIME = GETDATE(),@ReportId INT = 1,@ReportType INT = 1,@OdsCustomerId INT = 1;

DECLARE  @SQLScript VARCHAR(MAX)
		,@WhereClause VARCHAR(MAX);

-- Build Where clause to be used only when Claimant report or Bill Header Createdate report		
SET @WhereClause = CASE WHEN @ReportType IN(1,3) THEN 
CHAR(13)+CHAR(10)+'WHERE '
	+CASE WHEN @OdsCustomerId <> 0 THEN ' BH.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))ELSE '' END
	+CASE WHEN @ReportType = 1 THEN CASE WHEN @OdsCustomerId <> 0 THEN CHAR(13)+CHAR(10)+CHAR(9)+' AND ' ELSE '' END + ' CONVERT(VARCHAR(10),BH.CreateDate,112) BETWEEN '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+'''' ELSE '' END
	+CASE WHEN @OdsCustomerId <> 0 OR @ReportType = 1 THEN CHAR(13)+CHAR(10)+CHAR(9)+' AND ' ELSE '' END +' BH.Flags & 16 = 0;'  ELSE '' END


SET @SQLScript = '
DECLARE  @returnstatus INT
DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;

'+
CASE WHEN @OdsCustomerID <> 0 THEN '
EXEC adm.Rpt_CreateUnpartitionedTableSchema '+CAST(@OdsCustomerId AS VARCHAR(3))+',16,1,@returnstatus;
EXEC adm.Rpt_CreateUnpartitionedTableIndexes '+CAST(@OdsCustomerId AS VARCHAR(3))+',16,@returnstatus;
EXEC adm.Rpt_SwitchUnpartitionedTable '+CAST(@OdsCustomerId AS VARCHAR(3))+',16,'''',1,@returnstatus;

DROP TABLE stg.DP_PerformanceReport_Input_Unpartitioned;' 

ELSE '
TRUNCATE TABLE stg.DP_PerformanceReport_Input;' END+'

--Test: SELECT @start_dt,@end_dt'+
CASE WHEN @ReportType = 2 THEN '

-- Filter Bill History Data
IF OBJECT_ID(''tempdb..#Bill_History'') IS NOT NULL DROP TABLE #Bill_History
SELECT bhs.OdsCustomerId
	,bhs.billIDNo
	,max(bhs.DateCommitted) as DateCommitted 
INTO #Bill_History
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Bill_History' ELSE 'if_Bill_History(@RunPostingGroupAuditId)' END+ ' bhs
WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN ' bhs.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END +'CONVERT(VARCHAR(10),bhs.DateCommitted,112) BETWEEN '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+'''
GROUP BY bhs.OdsCustomerId
	,bhs.billIDNo; 
'
ELSE '' END+'

--Get Primary Diagnosis Code From CMT_DX table
IF OBJECT_ID(''tempdb..#Diagnosis'') IS NOT NULL DROP TABLE #Diagnosis;  /*Get Diagnosis Code*/
SELECT OdsCustomerId,BillIDNo,DX
INTO #Diagnosis
FROM (
SELECT C.OdsCustomerId
	,C.BillIDNo
	,C.DX
	, ROW_NUMBER() Over (Partition By OdsCustomerId,BillIDNo ORDER By SeqNum asc) Rnk
FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CMT_DX' ELSE 'if_CMT_DX(@RunPostingGroupAuditId)' END + ' C
'+CASE WHEN @OdsCustomerId <> 0 THEN 'WHERE C.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +' 
)X WHERE Rnk = 1;

--Get Provider Data into temp table
IF OBJECT_ID(''tempdb..#Provider'') IS NOT NULL DROP TABLE #Provider; 
SELECT DISTINCT 
	 OdsCustomerId
	,PvdIDNo
	,PvdSPC_List
	,Case WHEN SUBSTRING(PvdSPC_List,0,Charindex('':'',PvdSPC_List)) = ''XX'' THEN ''UNK''
				When PvdSPC_List LIKE ''%:%'' AND (LTRIM(RTRIM(PvdSPC_List)) LIKE ''%Unknown%'' OR LTRIM(RTRIM(PvdSPC_List)) = '''' OR LTRIM(RTRIM(PvdSPC_List)) IS NULL) Then ''UNK''
				When PvdSPC_List LIKE ''%:%'' Then SUBSTRING(PvdSPC_List,0,Charindex('':'',PvdSPC_List))
				When LTRIM(RTRIM(PvdSPC_List)) = '','' OR  LTRIM(RTRIM(PvdSPC_List)) IS NULL OR LTRIM(RTRIM(PvdSPC_List)) = '''' OR LTRIM(RTRIM(PvdSPC_List)) LIKE ''%Unknown%'' OR LTRIM(RTRIM(PvdSPC_List)) =''XX'' THEN ''UNK''
				Else PvdSPC_List End AS ProviderSpecialty
INTO #Provider
FROM '+@SourceDatabaseName+'.dbo.'+ CASE WHEN @RunType = 0 THEN 'PROVIDER' ELSE 'if_PROVIDER(@RunPostingGroupAuditId)' END +
CASE WHEN @OdsCustomerId <> 0 THEN ' WHERE  OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +  
'

CREATE NONCLUSTERED INDEX idx_Pvd ON #Provider(OdsCustomerId,PvdIDNo); 

-- Get Bills of interest
IF OBJECT_ID(''tempdb..#BILL_HDR'') IS NOT NULL DROP TABLE #BILL_HDR
SELECT DISTINCT
	 BH.OdsCustomerId
	,BH.BillIDNo
	,BH.CMT_HDR_IDNo'+CASE WHEN @ReportType = 2 THEN'
	,CONVERT(VARCHAR(8),bhs.DateCommitted,112) AS CreateDateformated
	,bhs.DateCommitted AS CreateDate'ELSE '	
	,CONVERT(VARCHAR(8),BH.CreateDate,112) AS CreateDateformated
	,BH.CreateDate' END +'
	,CASE WHEN BH.Flags & 4096 > 0 THEN ''UB-04''  ELSE ''CMS-1500''  END AS Form_Type
	,ISNULL(d.DX,-1) AS DiagnosisCode
	,BH.TypeOfBill
	,BH.CV_Type
	,LEFT(BH.PvdZOS,5) as ProviderZipOfService
INTO #BILL_HDR
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BILL_HDR' ELSE 'if_BILL_HDR(@RunPostingGroupAuditId)' END+' BH'+CASE WHEN @ReportType = 2 THEN '
INNER JOIN #Bill_History bhs ON BH.OdsCustomerId = bhs.OdsCustomerId 
	AND BH.BillIDNo = bhs.BillIDNo 
	AND BH.Flags & 16 = 0'  ELSE '' END+ '
LEFT OUTER JOIN #Diagnosis d ON BH.OdsCustomerId = d.OdsCustomerId
	AND BH.BillIDNo = d.BillIDNo '
+@WhereClause+'

	
--Add Lines, Claim and Claimant level InfO.
INSERT INTO stg.DP_PerformanceReport_Input(
		 OdsCustomerId
		,BillIDNo
		,CreateDate
		,Form_Type
		,ProviderZipOfService
		,TypeOfBill
		,DiagnosisCode
		,CompanyID
		,Company
		,OfficeID
		,Office
		,Coverage
		,ClaimNo
		,ClaimIDNo
		,CmtIDNO
		,SOJ
		,ProcedureCode
		,ProviderSpecialty
		,ProviderType
		,ProviderType_Desc
		,LINE_NO_DISP
		,LINE_NO
		,REF_LINE_NO
		,Line_Type
		,OVER_RIDE
		,CHARGED
		,ALLOWED
		,PreApportionedAmount
		,ANALYZED
		,UNITS
		,ReportType
)
SELECT   BH.OdsCustomerId
		,BH.BillIDNo
		,'+CASE WHEN @ReportType = 3 THEN 'CL.CreateDate' ELSE 'BH.CreateDate' END+'
		,BH.Form_Type
		,BH.ProviderZipOfService
		,BH.TypeOfBill
		,BH.DiagnosisCode
		,CL.CompanyID
		,ISNULL(CO.CompanyName, ''NA'') AS Company
		,CL.OfficeIndex
		,ISNULL(O.OfcName, ''NA'') AS Office
		'+
		CASE WHEN @ReportType <> 3 THEN ',COALESCE(BH.CV_type,CM.CoverageType,CL.CV_Code,'''')' ELSE ',CL.CV_Code' END+
		',CL.ClaimNo
		,CL.ClaimIDNo
		,CM.CmtIDNo
		,CM.CmtStateOfJurisdiction
		,B.PRC_CD AS ProcedureCode
		,P.ProviderSpecialty
		,ISNULL(SR.ProviderType,''UNK'') ProviderType
		,ISNULL(SR.ProviderType_Desc,''UNKNOWN'')  ProviderType_Desc
		,B.LINE_NO_DISP
		,B.LINE_NO
		,B.REF_LINE_NO
		,B.LineType
		,B.OVER_RIDE
		,B.CHARGED
		,B.ALLOWED
		,B.PreApportionedAmount
		,B.ANALYZED
		,B.UNITS
		,'+CAST(@ReportType AS VARCHAR(1))+'
FROM #BILL_HDR BH
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CMT_HDR' ELSE'if_CMT_HDR(@RunPostingGroupAuditId)' END+' CH 
	ON BH.OdsCustomerId = CH.OdsCustomerId
	AND BH.CMT_HDR_IDNo = CH.CMT_HDR_IDNo
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CLAIMANT' ELSE'if_CLAIMANT(@RunPostingGroupAuditId)' END+' CM 
	ON CH.OdsCustomerId = CM.OdsCustomerId
	AND CH.CmtIDNo = CM.CmtIDNo 
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CLAIMS' ELSE'if_CLAIMS(@RunPostingGroupAuditId)' END+' CL 
	ON  CM.OdsCustomerId = CL.OdsCustomerId
	AND CM.ClaimIDNo  = CL.ClaimIDNo
	AND CL.ClaimNo NOT LIKE ''%TEST%''
	AND(CL.OdsCustomerId NOT IN (70,71) OR CL.Status <> ''C'')'+
	CASE WHEN @ReportType = 3 THEN CHAR(13)+CHAR(10)+CHAR(9)+'AND CONVERT(VARCHAR(10),CL.CreateDate,112) BETWEEN '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+'''' ELSE '' END +'
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'prf_COMPANY' ELSE'if_prf_COMPANY(@RunPostingGroupAuditId)' END+' CO 
	ON CO.OdsCustomerId = CL.OdsCustomerId
	AND CO.CompanyID = CL.CompanyID
	AND CO.CompanyName NOT LIKE ''%TEST%''
	AND CO.CompanyName NOT LIKE ''%TRAIN%''	
INNER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'prf_Office' ELSE'if_prf_Office(@RunPostingGroupAuditId)' END+' O 
	ON O.OdsCustomerId = CL.OdsCustomerId
	AND O.OfficeID = CL.OfficeIndex
	AND O.OfcName NOT LIKE ''%TEST%''
	AND O.OfcName NOT LIKE ''%TRAIN%''
INNER JOIN (SELECT
				 OdsCustomerId 
				,BillIDNo
				,LINE_NO_DISP
				,LINE_NO
				,REF_LINE_NO
				,1 AS LineType
				,PRC_CD
				,OVER_RIDE
				,ISNULL(CHARGED, 0) CHARGED
				,ISNULL(ALLOWED, 0) ALLOWED
				,PreApportionedAmount
				,ISNULL(ANALYZED, 0) ANALYZED
				,ISNULL(UNITS, 0) UNITS
			FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BILLS' ELSE'if_BILLS(@RunPostingGroupAuditId)' END+' 
			WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN 'OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END +'CHARGED IS NOT NULL
			
			UNION 
			
			SELECT 
				 OdsCustomerId
				,BillIDNo
				,LINE_NO_DISP
				,LINE_NO
				,0
				,2 AS LineType
				,NDC
				,Override
				,ISNULL(CHARGED, 0) CHARGED
				,ISNULL(ALLOWED, 0) ALLOWED
				,PreApportionedAmount
				,ISNULL(ANALYZED, 0) ANALYZED
				,ISNULL(UNITS, 0) UNITS
			FROM  '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BILLS_Pharm' ELSE'if_BILLS_Pharm(@RunPostingGroupAuditId)' END+'
			WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN 'OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END +'CHARGED IS NOT NULL
			) AS B
	ON BH.OdsCustomerId = B.OdsCustomerId
	AND BH.BillIDNo = B.BillIDNo
LEFT OUTER JOIN #Provider P
	ON  P.OdsCustomerId = CH.OdsCustomerId
	AND P.PvdIDNo = CH.PvdIDNo 
LEFT OUTER JOIN  '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'ProviderSpecialtyToProvType' ELSE'if_ProviderSpecialtyToProvType(@RunPostingGroupAuditId)' END+' SR
	ON P.ProviderSpecialty = SR.Specialty;'
				
EXEC (@SQLScript);

END 

GO
