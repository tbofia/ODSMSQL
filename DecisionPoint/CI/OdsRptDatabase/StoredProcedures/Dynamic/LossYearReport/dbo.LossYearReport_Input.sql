IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.LossYearReport_Input') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.LossYearReport_Input
GO


CREATE PROCEDURE dbo.LossYearReport_Input (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@StartDate AS DATETIME,
@EndDate AS DATETIME,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 0,
@ReportId INT=5,
@ProcessId INT=1)
AS
BEGIN
--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',	@StartDate AS DATETIME = '2012-01-01',@EndDate AS DATETIME = '2016-12-31',@RunType INT = 0,	@if_Date AS DATETIME = NULL,@ProcessId INT = 5,@OdsCustomerId INT = 44;

DECLARE @SQLScript VARCHAR(MAX),
		@returnstatus INT; 

EXEC adm.Rpt_CreateUnpartitionedTableSchema @OdsCustomerId,@ProcessId,0,@returnstatus;

SET @SQLScript = CAST ('' AS VARCHAR(MAX)) + '
DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;

'+CASE WHEN @OdsCustomerID <> 0 THEN 
'DELETE FROM stg.LossYearReport_Input
WHERE OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5))+';' ELSE 

'TRUNCATE TABLE stg.LossYearReport_Input;' END+'

-- Filter CLAIMS data

IF OBJECT_ID(''tempdb..#CLAIMS'') IS NOT NULL DROP TABLE #CLAIMS;
SELECT CL.OdsCustomerId,
       CL.ClaimIDNo,
       CL.ClaimNo,
	   CL.DateLoss,
	   CL.CV_Code,
	   CL.LossState,
	   CL.Status,
	   CL.CompanyID
INTO #CLAIMS
FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CLAIMS' ELSE 'if_CLAIMS(@RunPostingGroupAuditId)' END + '  CL 
WHERE CL.CV_Code IN (''MP'',''PI'')'+
	CASE WHEN @OdsCustomerId <> 0 THEN 'AND CL.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +' 
	AND CL.DateLoss >= ''' + CAST(@StartDate AS VARCHAR(40)) + ''' AND  CL.DateLoss <= ''' + CAST(@EndDate AS VARCHAR(40))+ '''

CREATE CLUSTERED INDEX cidx_Cust_ClaimID 
ON #CLAIMS(OdsCustomerId, ClaimIDNo)

CREATE NONCLUSTERED INDEX nidx_Cust_ClaimID 
ON #CLAIMS(OdsCustomerId, ClaimIDNo,Status)
INCLUDE(ClaimNo, DateLoss,CV_Code, LossState, CompanyID)
'+

-- Filter BILL_HDR Data
'

IF OBJECT_ID(''tempdb..#Bill_HDR_Detail'') IS NOT NULL DROP TABLE #Bill_HDR_Detail;
SELECT BH.OdsCustomerId
	,BH.BillIDNo
	,BH.CMT_HDR_IDNo
	,CH.CmtIDNo
	,CH.PvdIDNo
	,BH.CreateDate
	,BH.OfficeId
	,LEFT(BH.PvdZOS, 5) PvdZOS
	,BH.TypeOfBill
	,CASE WHEN BH.Flags & 4096 > 0	THEN '' UB - 04 ''	ELSE '' CMS - 1500 ''	END AS Form_Type
	,BH.AdmissionDate
	,BH.DischargeDate
	,BH.ClaimDateLoss
	,BH.Flags & 16 AS Migrated
	,B.LINE_NO
	,B.LineType
	,B.PRC_CD
	,B.CHARGED
	,B.ALLOWED
	,B.ANALYZED
	,B.UNITS
	,B.DT_SVC
	,B.POS_RevCode
	,CASE WHEN (EX.Customer IS NOT NULL
		OR B.CHARGED > (B.UNITS*ISNULL(MCC.MaxChargedPerUnit,999999999999))
		OR B.UNITS > ISNULL(MCC.MaxUnitsPerEncounter,999999999999)
		OR B.CHARGED < 0
		OR B.UNITS < 0) THEN 1	ELSE 0 	END Outlier

INTO #Bill_HDR_Detail
FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'BILL_HDR' ELSE 'if_BILL_HDR(@RunPostingGroupAuditId)' END + ' BH
INNER JOIN (SELECT
				 OdsCustomerId 
				,BillIDNo
				,LINE_NO
				,1 AS LineType
				,PRC_CD
				,ISNULL(CHARGED, 0) CHARGED
				,ISNULL(ALLOWED, 0) ALLOWED
				,ISNULL(ANALYZED, 0) ANALYZED
				,ISNULL(UNITS, 0) UNITS
				,DT_SVC
				,POS_RevCode 
			FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'BILLS' ELSE 'if_BILLS(@RunPostingGroupAuditId)' END + 
			CASE WHEN @OdsCustomerId <> 0 THEN ' WHERE OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3))  ELSE '' END + '
									
			UNION ALL
			
			SELECT 
				 OdsCustomerId
				,BillIDNo
				,LINE_NO
				,2 AS LineType
				,NDC
				,ISNULL(CHARGED, 0) CHARGED
				,ISNULL(ALLOWED, 0) ALLOWED
				,ISNULL(ANALYZED, 0) ANALYZED
				,ISNULL(UNITS, 0) UNITS
				,DateOfService
				,POS_RevCode
			FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'BILLS_Pharm' ELSE 'if_BILLS_Pharm(@RunPostingGroupAuditId)' END + 
			CASE WHEN @OdsCustomerId <> 0 THEN ' WHERE OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3))  ELSE '' END + '
			) AS B
	ON BH.OdsCustomerId = B.OdsCustomerId
	AND BH.BillIDNo = B.BillIDNo
INNER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CMT_HDR' ELSE 'if_CMT_HDR(@RunPostingGroupAuditId)' END + ' CH 
	ON BH.OdsCustomerId = CH.OdsCustomerId
	AND BH.CMT_HDR_IDNo = CH.CMT_HDR_IDNo
LEFT OUTER JOIN '+@SourceDatabaseName+'.adm.Customer C
	ON BH.OdsCustomerId = C.CustomerId
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CustomerBillExclusion' ELSE 'if_CustomerBillExclusion(@RunPostingGroupAuditId)' END + ' EX 
	ON C.CustomerDatabase = EX.Customer
	AND BH.BillIDNo = EX.BillIdNo
	AND EX.ReportID = 4
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'MedicalCodeCutOffs' ELSE 'if_MedicalCodeCutOffs(@RunPostingGroupAuditId)' END + ' MCC
	ON CASE WHEN ISNULL(B.PRC_CD,'''') = '''' THEN B.POS_RevCode ELSE B.PRC_CD END = MCC.Code
	AND CASE WHEN BH.Flags & 4096 > 0 THEN ''UB-04''	ELSE ''CMS-1500''	END = MCC.FormType 
WHERE  BH.CreateDate >= ''' + CAST(@StartDate AS VARCHAR(40))+''''+
	CASE WHEN @OdsCustomerId <> 0 THEN ' AND BH.OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3)) ELSE '' END +'
	
CREATE CLUSTERED INDEX cidx_Cust_Bill_CMT 
ON #Bill_HDR_Detail(OdsCustomerId,BillIDNo)

CREATE NONCLUSTERED INDEX nidx_Cust_Bill_CMT 
ON #Bill_HDR_Detail(OdsCustomerId,BillIDNo,CMT_HDR_IDNo, Migrated, TypeOfBill,PvdZOS ) 
INCLUDE (CreateDate,OfficeId,ALLOWED,Form_Type,AdmissionDate,DischargeDate,ClaimDateLoss)'+

-- Get Allowed at Claimant level
'
IF OBJECT_ID('' tempdb..#Cmt_Allowed '') IS NOT NULL	DROP TABLE #Cmt_Allowed;
SELECT BH.OdsCustomerId
	,BH.CmtIDNo
	,SUM(BH.ALLOWED) Cmt_Allowed
INTO #Cmt_Allowed
FROM #Bill_HDR_Detail BH
WHERE Outlier = 0
	AND Migrated = 0
GROUP BY BH.OdsCustomerId
	,BH.CmtIDNo

CREATE NONCLUSTERED INDEX nidx_Cust_cmtIdNo 
ON #Cmt_Allowed(OdsCustomerId,CmtIDNo)
INCLUDE (Cmt_Allowed)
'
+

-- Get InjuryType Info By Claimant
'

IF OBJECT_ID(''tempdb..#InjuryNature'') IS NOT NULL DROP TABLE #InjuryNature;    
;WITH 
cte_IcdDiagnosisCodeDictionary AS(
SELECT dict.OdsCustomerID 
    ,dict.DiagnosisCode
    ,dict.IcdVersion
	,dict.InjuryNatureId
	,ROW_NUMBER() OVER (PARTITION BY OdsCustomerId, DiagnosisCode, IcdVersion ORDER BY StartDate DESC) rnk
FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'IcdDiagnosisCodeDictionary' ELSE 'if_IcdDiagnosisCodeDictionary(@RunPostingGroupAuditId)' END + ' dict
'+CASE WHEN @OdsCustomerId <> 0 THEN 'WHERE OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3))  ELSE '' END+'),

cte_InjuryNature AS(
SELECT cdx.OdsCustomerId
	,BH.CmtIDNo
	,cdx.BillIDNo
	,cdx.dx DiagnosisCode
	,cdx.IcdVersion
	,dict.InjuryNatureId 
	,ISNULL(I.[Description],''UNKNOWN'') InjuryNatureDesc
	,ROW_NUMBER() OVER (PARTITION BY cdx.OdsCustomerId,BH.CmtIDNo ORDER BY I.InjuryNaturePriority) rnk 
FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CMT_DX' ELSE 'if_CMT_DX(@RunPostingGroupAuditId)' END + ' cdx
INNER JOIN #Bill_HDR_Detail BH
     ON  BH.OdsCustomerID = cdx.OdsCustomerID
	 AND BH.BillIDNo = cdx.BillIDNo
INNER JOIN cte_IcdDiagnosisCodeDictionary dict
	ON  dict.OdsCustomerID = cdx.ODSCustomerID
    AND dict.DiagnosisCode = cdx.dx
    AND dict.IcdVersion = cdx.IcdVersion 
	AND dict.rnk = 1
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'InjuryNature' ELSE 'if_InjuryNature(@RunPostingGroupAuditId)' END + ' I 
	ON dict.OdsCustomerId = I.OdsCustomerId
	AND dict.InjuryNatureId = I.InjuryNatureId)

SELECT DISTINCT
	 OdsCustomerId
	,CmtIDNo
	,DiagnosisCode
	,IcdVersion
	,InjuryNatureId
	,InjuryNatureDesc
INTO #InjuryNature
FROM cte_InjuryNature Dx
WHERE Dx.rnk = 1


CREATE NONCLUSTERED INDEX nidx_CustIdCmtIDNo 
ON #InjuryNature(OdsCustomerId,CmtIDNo) 
INCLUDE (InjuryNatureId,InjuryNatureDesc)

IF OBJECT_ID(''tempdb..#ICD'') IS NOT NULL DROP TABLE #ICD;
SELECT OdsCustomerId,BILLIDNo,ICD9,IcdVersion,SeqNo
INTO #ICD
  FROM (
		  SELECT OdsCustomerId
			  ,BILLIDNo
			  ,ICD9
			  ,IcdVersion
			  ,SeqNo
			  ,ROW_NUMBER() OVER (Partition BY OdsCustomerId,BILLIDNo ORDER BY SeqNo) Rnk 
		  FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CMT_ICD9' ELSE 'if_CMT_ICD9(@RunPostingGroupAuditId)' END + 
		  CASE WHEN @OdsCustomerId <> 0 THEN ' WHERE OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3))  ELSE '' END + '
        ) X
  WHERE Rnk = 1

CREATE NONCLUSTERED INDEX indx_Cust_BillIDNO ON #ICD
(OdsCustomerId,BillIDNo) INCLUDE (ICD9,IcdVersion,SeqNo)'+

-- Populate Raw Data Table for Lost Year Report
'

INSERT INTO stg.LossYearReport_Input_Unpartitioned
SELECT BH.OdsCustomerId,
	   BH.BillIDNo,
	   BH.LINE_NO,
	   BH.LineType,
	   BH.CMT_HDR_IDNo,
	   CL.ClaimIDNo,
	   BH.CmtIDNo,
	   CL.DateLoss,
	   BH.CreateDate,
	   CL.DateLoss as AnchorDate, 
	   CAST((CAST(YEAR(CL.DateLoss) AS VARCHAR(4)) +''-''+ (CASE  WHEN CAST(DATEPART(QUARTER,CL.DateLoss) AS VARCHAR(1)) = ''1'' THEN ''01''
															   WHEN CAST(DATEPART(QUARTER,CL.DateLoss) AS VARCHAR(1)) = ''2'' THEN ''04''
															   WHEN CAST(DATEPART(QUARTER,CL.DateLoss) AS VARCHAR(1)) = ''3'' THEN ''07''
															   WHEN CAST(DATEPART(QUARTER,CL.DateLoss) AS VARCHAR(1)) = ''4'' THEN ''10'' END)+ ''-01'') AS DATETIME) AS AnchorDateQuarter, 
	   BH.OfficeId,
	   LEFT(BH.PvdZOS,5) PvdZOS, 
	   CASE WHEN LTRIM(RTRIM(ISNULL(Z.State,''UN''))) = '''' THEN ''UN'' ELSE ISNULL(Z.State,''UN'') END State,
       CASE WHEN LTRIM(RTRIM(ISNULL(Z.County,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(Z.County,''Unknown'') END County,
	   BH.TypeOfBill, 
	   BT.[Description] BillTypeDesc,
	   CL.CV_Code,
	   BH.Form_Type, 
	   BH.Migrated, 
	   BH.AdmissionDate,
	   BH.DischargeDate,
	   CM.CmtDOB,
	   CASE WHEN CM.CmtSEX NOT IN (''M'',''F'') THEN ''UN'' ELSE CM.CmtSEX END CmtSEX,
	   CASE WHEN LTRIM(RTRIM(ISNULL(CM.CmtStateOfJurisdiction,''UN''))) = '''' THEN ''UN'' ELSE ISNULL(CM.CmtStateOfJurisdiction,''UN'') END CmtStateOfJurisdiction,
	   CASE WHEN LTRIM(RTRIM(ISNULL(CM.CmtState,''UN''))) = '''' THEN ''UN'' ELSE ISNULL(CM.CmtState,''UN'') END CmtState,
	   CASE WHEN LTRIM(RTRIM(ISNULL(Zip.County,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(Zip.County,''Unknown'') END CmtCounty,
	   CM.CmtZip,
	   ISNULL(CO.CompanyName,''Unknown'') CompanyName,
	   BH.PRC_CD,
	   BH.POS_RevCode,
	   '''' POSDesc, /*POS.[Description] After brining the placeofservice table to ODS*/
	   BH.DT_SVC,
	   P.PvdIDNo,
	   LEFT(P.PvdZip,5) PvdZip,
	   CASE WHEN ISNULL(LTRIM(RTRIM(P.PvdSPC_List)),'''') = '''' THEN ''Uncategorized'' ELSE P.PvdSPC_List END AS PvdSPC_List,
	   P.PvdTitle,
	   CA.Cmt_Allowed,
	   BH.CHARGED,
	   BH.ALLOWED,
	   BH.UNITS,
	   DX.DiagnosisCode,
	   1 DX_SeqNum,
	   DX.IcdVersion DX_IcdVersion,
	   ICD9.ICD9 AS ICD,
	   ICD9.SeqNo AS ICD_SeqNum,
	   ICD9.IcdVersion AS ICD_IcdVersion, /*Do we have Icd10 version ?*/
	   DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) AS Period_Days, 
	   CASE 
	 	WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) < 0	THEN ''b4 dol''
	 	WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 0 AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 91 THEN ''1st Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 92 AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 182 THEN ''2nd Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 183 AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 273	THEN ''3rd Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 274 AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 365	THEN ''4th Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 366	AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 456 THEN ''5th Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 457	AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 547 THEN ''6th Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 548	AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 638 THEN ''7th Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 639	AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 730	THEN ''8th Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 731	THEN ''ultimate'' END Period,
	   DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) AS Age,
	   CASE 
		WHEN DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) >= 0 AND DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) <= 17	THEN ''minor''
		WHEN DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) >= 18	AND DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) <= 35	THEN ''young adult''
		WHEN DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) >= 36	AND DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) <= 49	THEN ''mature adult''
		WHEN DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) >= 50	THEN ''senior'' ELSE ''unknown''
		END AgeGroup,
	   CASE 
		WHEN  CA.Cmt_Allowed < 2500.01	THEN ''< 2500''
		WHEN  CA.Cmt_Allowed >= 2500.01	AND  CA.Cmt_Allowed < 5000.01	THEN ''between 2500_5000''
		WHEN  CA.Cmt_Allowed >= 5000.01	AND  CA.Cmt_Allowed < 10000.01	THEN ''between 5000_10000''
		WHEN  CA.Cmt_Allowed >= 10000.01	AND  CA.Cmt_Allowed < 15000.01	THEN ''between 10000_15000''
		WHEN  CA.Cmt_Allowed >= 15000.01	AND  CA.Cmt_Allowed < 25000.01	THEN ''between 15000_25000''
		WHEN  CA.Cmt_Allowed >= 25000.01	AND  CA.Cmt_Allowed < 50000.01	THEN ''between 25000_50000''
		WHEN  CA.Cmt_Allowed >= 50000.01	THEN ''> 50000''
		END  Outlier_cat, '
		+ CAST ('' AS VARCHAR(MAX)) + '
	   '''' Bill_Type, /*Get the rules from HIM team for InPatient, Outpatient, ER and Asc*/ 
	   '''' DX_Score, /*Dependent on HIM team and probably out of scope for this PSI*/
	   '''' er_bill_flag, /*Flag if a Bill is ER type or not*/
	   RCSC.RevenueCodeCategoryId,
	   YEAR(CL.DateLoss) AS YOL,
	   CASE WHEN ISNULL(LTRIM(RTRIM(PCG.MinorCategory)),'''') = '''' THEN ''Uncategorized'' ELSE PCG.MinorCategory END AS ServiceGroup,
	   BH.Outlier,
	   CASE WHEN DX.InjuryNatureId IS NULL THEN 24 ELSE DX.InjuryNatureId END AS InjuryNatureId,
	   CASE WHEN (BH.Form_Type = ''CMS-1500'' and BH.POS_RevCode IN (''0'', ''23'')) or (BH.Form_Type = ''UB-04''  and BH.TypeOfBill = ''0131'' and BH.POS_RevCode = ''0450'') THEN 2 /*Emergency Room*/
	        WHEN ((BH.Form_Type = ''CMS-1500''  and BH.POS_RevCode = ''21'') or (BH.Form_Type = ''UB-04'' and BH.TypeOfBill LIKE ''011%'')) THEN 1 /*Inpatient*/
		   WHEN ((BH.Form_Type = ''CMS-1500''   and BH.POS_RevCode = ''24'') or (BH.Form_Type = ''UB-04'' and BH.TypeOfBill LIKE ''083%'')) THEN 3 /*Ambulatory Surgical Center*/
		   WHEN (BH.Form_Type = ''CMS-1500'' and BH.POS_RevCode = ''11'')  THEN 4 /*Professional Office Visit*/
		   WHEN ((BH.Form_Type = ''UB-04'' and ((BH.TypeOfBill LIKE ''013%'') or (BH.TypeOfBill LIKE ''014%'') or (BH.TypeOfBill LIKE ''074%'') or (BH.TypeOfBill LIKE ''075%''))) and BH.POS_RevCode NOT like ''045%'') or (BH.Form_Type = ''CMS-1500'' and BH.POS_RevCode IN (''19'',''22'',''61'')) THEN 5 /*Outpatient*/
		   WHEN (BH.Form_Type = ''UB-04'' and ((BH.TypeOfBill like ''02%'') or (BH.TypeOfBill like ''03%''))) OR (BH.Form_Type = ''CMS-1500'' and BH.POS_RevCode in (''12'',''31'',''32'',''33'')) THEN 6 /*Skilled Nursing/Home Health*/
        ELSE 7 /*Other*/ END EncounterTypeId,
	  GETDATE() AS Rundate
FROM  #Bill_HDR_Detail BH
INNER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CLAIMANT' ELSE 'if_CLAIMANT(@RunPostingGroupAuditId)' END + ' CM 
	ON BH.OdsCustomerId = CM.OdsCustomerId
	AND BH.CmtIDNo = CM.CmtIDNo 
INNER JOIN #Cmt_Allowed CA 
	ON CM.OdsCustomerId = CA.OdsCustomerId
	AND CM.CmtIDNo = CA.CmtIDNo
INNER JOIN #CLAIMS CL 
	ON  CM.OdsCustomerId = CL.OdsCustomerId
	AND CM.ClaimIDNo  = CL.ClaimIDNo
	AND CL.ClaimNo NOT LIKE ''%TEST%''
	AND(CL.OdsCustomerId NOT IN (70,71) OR CL.Status <> ''C'')
INNER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'prf_COMPANY' ELSE 'if_prf_COMPANY(@RunPostingGroupAuditId)' END + ' CO 
	ON CO.OdsCustomerId = CL.OdsCustomerId
	AND CO.CompanyID = CL.CompanyID
	AND CO.CompanyName NOT LIKE ''%TEST%''
	AND CO.CompanyName NOT LIKE ''%TRAIN%''	
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'PROVIDER' ELSE 'if_PROVIDER(@RunPostingGroupAuditId)' END + ' P 
	ON  P.OdsCustomerId = BH.OdsCustomerId
	AND P.PvdIDNo = BH.PvdIDNo
LEFT OUTER JOIN #ICD ICD9
	ON  BH.OdsCustomerId = ICD9.OdsCustomerId
	AND BH.BillIDNo = ICD9.BillIDNo
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'UB_BillType' ELSE 'if_UB_BillType(@RunPostingGroupAuditId)' END + ' BT 
	ON BH.OdsCustomerId = BT.OdsCustomerId
	AND BH.TypeOfBill = BT.TOB
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'ProcedureCodeGroup' ELSE 'if_ProcedureCodeGroup(@RunPostingGroupAuditId)' END + ' PCG 
	ON BH.OdsCustomerId = PCG.OdsCustomerId
	AND BH.PRC_CD = PCG.ProcedureCode
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'UB_RevenueCodes' ELSE 'if_UB_RevenueCodes(@RunPostingGroupAuditId)' END + ' RC 
	ON BH.OdsCustomerId = RC.OdsCustomerId
	AND BH.POS_RevCode = RC.RevenueCode
	AND BH.CreateDate BETWEEN RC.StartDate AND RC.EndDate
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'RevenueCodeSubcategory' ELSE 'if_RevenueCodeSubcategory(@RunPostingGroupAuditId)' END + ' RCSC 
	ON RC.OdsCustomerId = RCSC.OdsCustomerId
	AND RC.RevenueCodeSubCategoryId = RCSC.RevenueCodeSubCategoryId
LEFT OUTER JOIN (SELECT * FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'ZipCode' ELSE 'if_ZipCode(@RunPostingGroupAuditId)' END + ' WHERE PrimaryRecord = 1) Z
	ON BH.OdsCustomerId = Z.OdsCustomerId
	AND LEFT(BH.PvdZOS,5) = Z.ZipCode
LEFT OUTER JOIN (SELECT * FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'ZipCode' ELSE 'if_ZipCode(@RunPostingGroupAuditId)' END + ' WHERE PrimaryRecord = 1) Zip
	ON CM.OdsCustomerId = Zip.OdsCustomerId
	AND LEFT(CM.CmtZip,5) = Zip.ZipCode	
LEFT OUTER JOIN #InjuryNature DX
    ON  DX.OdsCustomerID = BH.ODSCustomerID
    AND DX.CmtIDNo = BH.CmtIDNo
WHERE BH.Migrated = 0
OPTION (MERGE JOIN, HASH JOIN) '


+ CAST ('' AS VARCHAR(MAX)) + '


/*****************3rd Party*************/

/****Get Claimants with Min(Bill Date Created) "DemandCreateDate" in last rolling 5 years****/
IF OBJECT_ID(''tempdb..#DemandCreateDate'') IS NOT NULL DROP TABLE #DemandCreateDate;
SELECT CH.OdsCustomerId
      ,CM.ClaimIdNo
      ,CH.CmtIdNo
      ,MIN(BH.CreateDate) DemandCreateDate
INTO #DemandCreateDate
FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'BILL_HDR' ELSE 'if_BILL_HDR(@RunPostingGroupAuditId)' END + '  BH  
INNER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CMT_HDR' ELSE 'if_CMT_HDR(@RunPostingGroupAuditId)' END + '  CH  
	ON BH.OdsCustomerId = CH.OdsCustomerId
	AND BH.CMT_HDR_IDNo = CH.CMT_HDR_IDNo
INNER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CLAIMANT' ELSE 'if_CLAIMANT(@RunPostingGroupAuditId)' END + '  CM
	ON CH.OdsCustomerId = CM.OdsCustomerId
	AND CH.CmtIDNo = CM.CmtIDNo 
INNER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CLAIMS' ELSE 'if_CLAIMS(@RunPostingGroupAuditId)' END + '  CL  
	ON  CM.OdsCustomerId = CL.OdsCustomerId
	AND CM.ClaimIDNo  = CL.ClaimIDNo
	AND CL.CV_Code IN (''AL'',''GL'',''UM'',''UN'') /*3rd party Claims Only*/ ' +
CASE WHEN @OdsCustomerId <> 0 THEN ' WHERE BH.OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3))  ELSE '' END + '
GROUP BY CH.OdsCustomerId
        ,CM.ClaimIdNo
        ,CH.CmtIdNo
HAVING MIN(BH.CreateDate) >= ''' + CAST(@StartDate AS VARCHAR(40))  + ''' AND MIN(BH.CreateDate) <= ''' + CAST(@EndDate AS VARCHAR(40))  + ''' 
OPTION (MERGE JOIN, HASH JOIN)

CREATE NONCLUSTERED INDEX cidx_Cust_ClaimId_CmtId ON #DemandCreateDate
(OdsCustomerId, ClaimIdNo, CmtIdNo) INCLUDE (DemandCreateDate);



INSERT INTO stg.LossYearReport_Input_Unpartitioned
SELECT BH.OdsCustomerId,
	   BH.BillIDNo,
	   BH.LINE_NO,
	   BH.LineType,
	   BH.CMT_HDR_IDNo,
	   CL.ClaimIDNo,
	   BH.CmtIDNo,
	   CL.DateLoss,
	   BH.CreateDate,
	   DMD.DemandCreateDate AS AnchorDate,/*Demand Create Date is the anchor date for 3rd party*/
	   CAST((CAST(YEAR(DMD.DemandCreateDate) AS VARCHAR(4)) +''-''+ (CASE  WHEN CAST(DATEPART(QUARTER,DMD.DemandCreateDate) AS VARCHAR(1)) = ''1'' THEN ''01''
															   WHEN CAST(DATEPART(QUARTER,DMD.DemandCreateDate) AS VARCHAR(1)) = ''2'' THEN ''04''
															   WHEN CAST(DATEPART(QUARTER,DMD.DemandCreateDate) AS VARCHAR(1)) = ''3'' THEN ''07''
															   WHEN CAST(DATEPART(QUARTER,DMD.DemandCreateDate) AS VARCHAR(1)) = ''4'' THEN ''10'' END)+ ''-01'') AS DATETIME) AS AnchorDateQuarter,
	   BH.OfficeId,
	   LEFT(BH.PvdZOS,5) PvdZOS, 
	   CASE WHEN LTRIM(RTRIM(ISNULL(Z.State,''UN''))) = '''' THEN ''UN'' ELSE ISNULL(Z.State,''UN'') END State,
       CASE WHEN LTRIM(RTRIM(ISNULL(Z.County,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(Z.County,''Unknown'') END County,
	   BH.TypeOfBill, 
	   BT.[Description] BillTypeDesc,
	   CL.CV_Code,
	   BH.Form_Type,
	   BH.Migrated, 
	   BH.AdmissionDate,
	   BH.DischargeDate,
	   CM.CmtDOB,
	   CASE WHEN CM.CmtSEX NOT IN (''M'',''F'') THEN ''UN'' ELSE CM.CmtSEX END CmtSEX,
	   CASE WHEN LTRIM(RTRIM(ISNULL(CM.CmtStateOfJurisdiction,''UN''))) = '''' THEN ''UN'' ELSE ISNULL(CM.CmtStateOfJurisdiction,''UN'') END CmtStateOfJurisdiction,
	   CASE WHEN LTRIM(RTRIM(ISNULL(CM.CmtState,''UN''))) = '''' THEN ''UN'' ELSE ISNULL(CM.CmtState,''UN'') END CmtState,
	   CASE WHEN LTRIM(RTRIM(ISNULL(Zip.County,''Unknown''))) = '''' THEN ''Unknown'' ELSE ISNULL(Zip.County,''Unknown'') END CmtCounty,
	   CM.CmtZip,
	   ISNULL(CO.CompanyName,''Unknown'') CompanyName,
	   BH.PRC_CD,
	   BH.POS_RevCode,
	   '''' POSDesc, /*POS.[Description] After brining the placeofservice table to ODS*/
	   BH.DT_SVC,
	   P.PvdIDNo,
	   LEFT(P.PvdZip,5) PvdZip,
	   CASE WHEN ISNULL(LTRIM(RTRIM(P.PvdSPC_List)),'''') = '''' THEN ''Uncategorized'' ELSE P.PvdSPC_List END AS PvdSPC_List,
	   P.PvdTitle,
	   CA.Cmt_Allowed,
	   BH.CHARGED,
	   BH.ALLOWED,
	   BH.UNITS,
	   DX.DiagnosisCode,
	   1 DX_SeqNum,
	   DX.IcdVersion DX_IcdVersion,
	   ICD9.ICD9 AS ICD,
	   ICD9.SeqNo AS ICD_SeqNum,
	   ICD9.IcdVersion AS ICD_IcdVersion, /*Do we have Icd10 version ?*/
	   DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) AS Period_Days, /*Ed has used BH.CreateDate but He mentioned ideally we should be using DateOfService*/  
	   CASE 
	 	WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) < 0	THEN ''b4 dol''
	 	WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 0 AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 91 THEN ''1st Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 92 AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 182 THEN ''2nd Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 183 AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 273	THEN ''3rd Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 274 AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 365	THEN ''4th Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 366	AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 456 THEN ''5th Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 457	AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 547 THEN ''6th Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 548	AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 638 THEN ''7th Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 639	AND DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) <= 730	THEN ''8th Quarter''
		WHEN DATEDIFF(dd,BH.ClaimDateLoss,BH.DT_SVC) >= 731	THEN ''ultimate'' END Period,
	   DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) AS Age,
	   CASE 
		WHEN DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) >= 0 AND DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) <= 17	THEN ''minor''
		WHEN DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) >= 18	AND DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) <= 35	THEN ''young adult''
		WHEN DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) >= 36	AND DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) <= 49	THEN ''mature adult''
		WHEN DATEDIFF(yy,CM.CmtDOB,CL.DateLoss) >= 50	THEN ''senior'' ELSE ''unknown''
		END AgeGroup,
	   CASE 
		WHEN  CA.Cmt_Allowed < 2500.01	THEN ''< 2500''
		WHEN  CA.Cmt_Allowed >= 2500.01	AND  CA.Cmt_Allowed < 5000.01	THEN ''between 2500_5000''
		WHEN  CA.Cmt_Allowed >= 5000.01	AND  CA.Cmt_Allowed < 10000.01	THEN ''between 5000_10000''
		WHEN  CA.Cmt_Allowed >= 10000.01 AND  CA.Cmt_Allowed < 15000.01	THEN ''between 10000_15000''
		WHEN  CA.Cmt_Allowed >= 15000.01 AND  CA.Cmt_Allowed < 25000.01	THEN ''between 15000_25000''
		WHEN  CA.Cmt_Allowed >= 25000.01 AND  CA.Cmt_Allowed < 50000.01	THEN ''between 25000_50000''
		WHEN  CA.Cmt_Allowed >= 50000.01 THEN ''> 50000''
		END  Outlier_cat, '
		+ CAST ('' AS VARCHAR(MAX)) + '
	   '''' Bill_Type, /*Get the rules from HIM team for InPatient, Outpatient, ER and Asc*/ 
	   '''' DX_Score, /*Dependent on HIM team and probably out of scope for this PSI*/
	   '''' er_bill_flag, /*Flag if a Bill is ER type or not*/
	   RCSC.RevenueCodeCategoryId,
	   YEAR(CL.DateLoss) AS YOL,
	   CASE WHEN ISNULL(LTRIM(RTRIM(PCG.MinorCategory)),'''') = '''' THEN ''Uncategorized'' ELSE PCG.MinorCategory END AS ServiceGroup,
	   BH.Outlier,
	   DX.InjuryNatureId,
	    CASE WHEN (BH.Form_Type = ''CMS-1500'' and BH.POS_RevCode IN (''0'', ''23'')) or (BH.Form_Type = ''UB-04''  and BH.TypeOfBill = ''0131'' and BH.POS_RevCode = ''0450'') THEN 2 /*Emergency Room*/
	        WHEN ((BH.Form_Type = ''CMS-1500''  and BH.POS_RevCode = ''21'') or (BH.Form_Type = ''UB-04'' and BH.TypeOfBill LIKE ''011%'')) THEN 1 /*Inpatient*/
		   WHEN ((BH.Form_Type = ''CMS-1500''   and BH.POS_RevCode = ''24'') or (BH.Form_Type = ''UB-04'' and BH.TypeOfBill LIKE ''083%'')) THEN 3 /*Ambulatory Surgical Center*/
		   WHEN (BH.Form_Type = ''CMS-1500'' and BH.POS_RevCode = ''11'')  THEN 4 /*Professional Office Visit*/
		   WHEN ((BH.Form_Type = ''UB-04'' and ((BH.TypeOfBill LIKE ''013%'') or (BH.TypeOfBill LIKE ''014%'') or (BH.TypeOfBill LIKE ''074%'') or (BH.TypeOfBill LIKE ''075%''))) and BH.POS_RevCode NOT like ''045%'') or (BH.Form_Type = ''CMS-1500'' and BH.POS_RevCode IN (''19'',''22'',''61'')) THEN 5 /*Outpatient*/
		   WHEN (BH.Form_Type = ''UB-04'' and ((BH.TypeOfBill like ''02%'') or (BH.TypeOfBill like ''03%''))) OR (BH.Form_Type = ''CMS-1500'' and BH.POS_RevCode in (''12'',''31'',''32'',''33'')) THEN 6 /*Skilled Nursing/Home Health*/
        ELSE 7 /*Other*/ END EncounterTypeId,
		GETDATE() AS Rundate
FROM  #Bill_HDR_Detail BH
INNER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CLAIMANT' ELSE 'if_CLAIMANT(@RunPostingGroupAuditId)' END + ' CM 
	ON BH.OdsCustomerId = CM.OdsCustomerId
	AND BH.CmtIDNo = CM.CmtIDNo 
INNER JOIN #Cmt_Allowed CA 
	ON CM.OdsCustomerId = CA.OdsCustomerId
	AND CM.CmtIDNo = CA.CmtIDNo
INNER JOIN #DemandCreateDate DMD
	ON CM.OdsCustomerId = DMD.OdsCustomerId
	AND CM.CmtIDNo = DMD.CmtIDNo
INNER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CLAIMS' ELSE 'if_CLAIMS(@RunPostingGroupAuditId)' END + ' CL  
	ON  CM.OdsCustomerId = CL.OdsCustomerId
	AND CM.ClaimIDNo  = CL.ClaimIDNo
	AND CL.ClaimNo NOT LIKE ''%TEST%''
	AND(CL.OdsCustomerId NOT IN (70,71) OR CL.Status <> ''C'')
INNER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'prf_COMPANY' ELSE 'if_prf_COMPANY(@RunPostingGroupAuditId)' END + ' CO 
	ON CO.OdsCustomerId = CL.OdsCustomerId
	AND CO.CompanyID = CL.CompanyID
	AND CO.CompanyName NOT LIKE ''%TEST%''
	AND CO.CompanyName NOT LIKE ''%TRAIN%''	
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'PROVIDER' ELSE 'if_PROVIDER(@RunPostingGroupAuditId)' END + ' P 
	ON  P.OdsCustomerId = BH.OdsCustomerId
	AND P.PvdIDNo = BH.PvdIDNo
LEFT OUTER JOIN #ICD ICD9
	ON  BH.OdsCustomerId = ICD9.OdsCustomerId
	AND BH.BillIDNo = ICD9.BillIDNo
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'UB_BillType' ELSE 'if_UB_BillType(@RunPostingGroupAuditId)' END + ' BT 
	ON BH.OdsCustomerId = BT.OdsCustomerId
	AND BH.TypeOfBill = BT.TOB
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'ProcedureCodeGroup' ELSE 'if_ProcedureCodeGroup(@RunPostingGroupAuditId)' END + ' PCG 
	ON BH.OdsCustomerId = PCG.OdsCustomerId
	AND BH.PRC_CD = PCG.ProcedureCode
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'UB_RevenueCodes' ELSE 'if_UB_RevenueCodes(@RunPostingGroupAuditId)' END + ' RC 
	ON BH.OdsCustomerId = RC.OdsCustomerId
	AND BH.POS_RevCode = RC.RevenueCode
	AND BH.CreateDate BETWEEN RC.StartDate AND RC.EndDate
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'RevenueCodeSubcategory' ELSE 'if_RevenueCodeSubcategory(@RunPostingGroupAuditId)' END + ' RCSC 
	ON RC.OdsCustomerId = RCSC.OdsCustomerId
	AND RC.RevenueCodeSubCategoryId = RCSC.RevenueCodeSubCategoryId
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'ZipCode' ELSE 'if_ZipCode(@RunPostingGroupAuditId)' END + ' Z
	ON BH.OdsCustomerId = Z.OdsCustomerId
	AND LEFT(BH.PvdZOS,5) = Z.ZipCode
	AND Z.PrimaryRecord = 1
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'ZipCode' ELSE 'if_ZipCode(@RunPostingGroupAuditId)' END + ' Zip
	ON CM.OdsCustomerId = Zip.OdsCustomerId
	AND LEFT(CM.CmtZip,5) = Zip.ZipCode	
	AND Zip.PrimaryRecord = 1
LEFT OUTER JOIN #InjuryNature DX
     ON  DX.OdsCustomerID = BH.ODSCustomerID
     AND DX.CmtIDNo = BH.CmtIDNo
WHERE BH.Migrated = 0  

OPTION (MERGE JOIN, HASH JOIN);'

EXEC (@SQLScript);

EXEC adm.Rpt_CreateUnpartitionedTableIndexes @OdsCustomerId,@ProcessId,@returnstatus;
EXEC adm.Rpt_SwitchUnpartitionedTable @OdsCustomerId,@ProcessId,'',0,@returnstatus;

END

GO
