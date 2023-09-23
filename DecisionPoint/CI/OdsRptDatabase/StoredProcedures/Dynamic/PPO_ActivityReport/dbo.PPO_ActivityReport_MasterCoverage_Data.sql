IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.PPO_ActivityReport_MasterCoverage_Data') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PPO_ActivityReport_MasterCoverage_Data
GO


CREATE PROCEDURE dbo.PPO_ActivityReport_MasterCoverage_Data (
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

-- Build Where clause 
SET @WhereClause = CASE WHEN @ReportType IN(1,3) THEN 
CHAR(13)+CHAR(10)+'WHERE '
	+CASE WHEN @OdsCustomerId <> 0 THEN ' BH.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))ELSE '' END
	+CASE WHEN @ReportType = 1 THEN CASE WHEN @OdsCustomerId <> 0 THEN CHAR(13)+CHAR(10)+CHAR(9)+' AND ' ELSE '' END + ' CONVERT(VARCHAR(10),BH.CreateDate,112) BETWEEN '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+'''' ELSE '' END
	+CASE WHEN @OdsCustomerId <> 0 OR @ReportType = 1 THEN CHAR(13)+CHAR(10)+CHAR(9)+' AND ' ELSE '' END +' BH.Flags & 16 = 0;'  ELSE '' END


SET @SQLScript = '
DECLARE  @returnstatus INT
DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;

TRUNCATE TABLE stg.PPO_ActivityReport_MasterCoverage_Input;

--Test: SELECT @start_dt,@end_dt
-- Get Bills of interest
IF OBJECT_ID(''tempdb..#BILL_HDR'') IS NOT NULL DROP TABLE #BILL_HDR
SELECT DISTINCT
	 BH.OdsCustomerId
	,BH.BillIDNo
	,BH.CMT_HDR_IDNo
	,CONVERT(VARCHAR(8),BH.CreateDate,112) AS CreateDateformated
	,BH.CreateDate
	,CASE WHEN BH.Flags & 4096 > 0 THEN ''UB-04''  ELSE ''CMS-1500''  END AS Form_Type
	,BH.TypeOfBill
	,BH.CV_Type
	,LEFT(BH.PvdZOS,5) as ProviderZipOfService
INTO #BILL_HDR
FROM '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BILL_HDR' ELSE 'if_BILL_HDR(@RunPostingGroupAuditId)' END+' BH'
+@WhereClause+'

	
--Add Lines, Claim and Claimant level InfO.
INSERT INTO stg.PPO_ActivityReport_MasterCoverage_Input( 
		 OdsCustomerId
		,BillIDNo
		,CreateDate
		,Form_Type
		,TypeOfBill
		,CompanyID
		,Company
		,OfficeID
		,Office
		,Coverage
		,SOJ
		,LINE_NO_DISP
		,LINE_NO
		,REF_LINE_NO
		,LineType
		,OVER_RIDE
		,CHARGED
		,ALLOWED
		,PreApportionedAmount
		,ANALYZED
		,UNITS
		,ReportTypeId)
SELECT   BH.OdsCustomerId
		,BH.BillIDNo
		,BH.CreateDate
		,BH.Form_Type
		,BH.TypeOfBill
		,CL.CompanyID
		,ISNULL(CO.CompanyName, ''NA'') AS Company
		,CL.OfficeIndex
		,ISNULL(O.OfcName, ''NA'') AS Office
		,COALESCE(BH.CV_type,CM.CoverageType,CL.CV_Code,'''') AS Coverage
		,CM.CmtStateOfJurisdiction AS SOJ
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
		,'+CAST(@ReportType AS VARCHAR(1))+' AS ReportTypeId

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
	AND(CL.OdsCustomerId NOT IN (70,71) OR CL.Status <> ''C'')
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
	AND BH.BillIDNo = B.BillIDNo'
				
EXEC (@SQLScript);

END 

GO
