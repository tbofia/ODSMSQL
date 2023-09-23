IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.ERDReport_Output') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ERDReport_Output
GO

CREATE PROCEDURE dbo.ERDReport_Output (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@StartDate AS DATETIME,
@EndDate AS DATETIME,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@ReportID INT,
@OdsCustomerId INT = 0,
@TargetDatabaseName VARCHAR(50) = 'ReportDB')
AS
BEGIN


--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@StartDate AS DATETIME = '2012-01-01',@EndDate AS DATETIME = '2016-12-31',RunType INT = 0,@if_Date AS DATETIME = NULL,@ReportID INT = 6,@OdsCustomerId INT = 82;

DECLARE @SQLScript VARCHAR(MAX) 

SET @SQLScript = CAST ('' AS VARCHAR(MAX)) + '
DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;

'+CASE WHEN @OdsCustomerID <> 0 THEN 
'DELETE FROM '+@TargetDatabaseName+'.dbo.ERDReport
WHERE OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5))+';' ELSE 

'TRUNCATE TABLE '+@TargetDatabaseName+'.dbo.ERDReport;' END+'

--1) Get Bill Exclusion Info
IF OBJECT_ID(''tempdb..#Outlier'') IS NOT NULL DROP TABLE #Outlier;
SELECT C.CustomerId
	,B.BillIdNo
INTO #Outlier
FROM '+@SourceDatabaseName+'.adm.Customer C
JOIN  '+@SourceDatabaseName+'.dbo.CustomerBillExclusion B
ON C.CustomerDatabase = B.Customer
Where B.ReportID = ' + CAST (@ReportID as Varchar(2))  + 


--2) Get Claims info
'
IF OBJECT_ID(''tempdb..#CLAIMS'') IS NOT NULL DROP TABLE #CLAIMS;  
SELECT OdsCustomerId
	,ClaimIDNo
	,ClaimNo
	,CV_Code
	,DateLoss
	,CompanyID
	,OfficeIndex
	,AdjIdNo
	,[Status]  --24 sec
INTO #CLAIMS
FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CLAIMS' ELSE 'if_CLAIMS(@RunPostingGroupAuditId)' END + ' CL 
WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN 'CL.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) + ' AND ' ELSE '' END +' 
       CONVERT(VARCHAR(10),CL.DateLoss,112) BETWEEN '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+'''

CREATE CLUSTERED INDEX cidx_CustIdClaimIdNo ON #CLAIMS
(OdsCustomerId,ClaimIDNo)

 ' +

--3) Get Bill_Hdr info
'

IF OBJECT_ID(''tempdb..#BILL_HDR'') IS NOT NULL DROP TABLE #BILL_HDR;    
SELECT BH.OdsCustomerId
	,BH.BillIDNo
	,BH.CMT_HDR_IDNo
	,ClaimDateLoss
	,CH.CmtIDNo
	,BH.Flags & 16 AS Migrated
	,BH.AmtAllowed
	,BH.AmtCharged  --2min
INTO #BILL_HDR
FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'BILL_HDR' ELSE 'if_BILL_HDR(@RunPostingGroupAuditId)' END + ' BH
INNER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CMT_HDR' ELSE 'if_CMT_HDR(@RunPostingGroupAuditId)' END + ' CH
ON CH.OdsCustomerID = BH.OdsCustomerID 
    AND BH.CMT_HDR_IDNo = CH.CMT_HDR_IDNo
LEFT JOIN #Outlier O
	ON BH.OdsCustomerId = O.CustomerId
	AND BH.billIDNo = O.BillIdNo
WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN 'BH.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3)) + ' AND ' ELSE '' END +'
       CONVERT(VARCHAR(10),BH.CreateDate,112) > '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND O.CustomerId IS NULL

CREATE NONCLUSTERED INDEX nidx_CustIdCmtIDNoBillIDNo 
ON #BILL_HDR(OdsCustomerId,CmtIDNo,BillIDNo) 
INCLUDE(AmtAllowed,AmtCharged)

--4) Get Duration and InjuryType Info 

IF OBJECT_ID(''tempdb..#InjuryNature'') IS NOT NULL DROP TABLE #InjuryNature;    
SELECT DISTINCT OdsCustomerId
	,CmtIDNo
	,Duration
	,InjuryNatureId
	,InjuryNatureDesc
INTO #InjuryNature
FROM (
SELECT cdx.OdsCustomerId
	,BH.CmtIDNo
	,cdx.BillIDNo
	,dx.DiagnosisCode
	,ISNULL(dx.Duration,0) Duration
	,ISNULL(I.InjuryNatureId,99) InjuryNatureId
	,ISNULL(I.[Description],''Unknown'') InjuryNatureDesc
	,I.InjuryNaturePriority
	,ROW_NUMBER() OVER (PARTITION BY cdx.OdsCustomerId,bh.CmtIDNo ORDER BY ISNULL(dx.Duration,0) desc,InjuryNaturePriority desc) rnk 
FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CMT_DX' ELSE 'if_CMT_DX(@RunPostingGroupAuditId)' END + ' cdx  
INNER JOIN #BILL_HDR BH
     ON  BH.OdsCustomerID = cdx.OdsCustomerID
	AND BH.BillIDNo = cdx.BillIDNo
LEFT JOIN (
     SELECT 
	    OdsCustomerID,
		ICD9 AS DiagnosisCode,
		Duration,
		9 AS IcdVersion
	FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'cpt_DX_DICT' ELSE 'if_cpt_DX_DICT(@RunPostingGroupAuditId)' END +  
	CASE WHEN @OdsCustomerId <> 0 THEN ' WHERE OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3))  ELSE '' END + ' 
	
	UNION ALL
	
	SELECT 
	    OdsCustomerID,
		DiagnosisCode,
		Duration,
		10 AS IcdVersion
    FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'Icd10DiagnosisVersion' ELSE 'if_Icd10DiagnosisVersion(@RunPostingGroupAuditId)' END + 
    CASE WHEN @OdsCustomerId <> 0 THEN ' WHERE OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3))  ELSE '' END + ' 
)dx
    ON  dx.OdsCustomerID = cdx.ODSCustomerID
    AND dx.DiagnosisCode = cdx.dx
    AND dx.IcdVersion = cdx.IcdVersion  
LEFT JOIN (   SELECT OdsCustomerId, DiagnosisCode, IcdVersion, InjuryNatureId
		    FROM (
		    SELECT OdsCustomerId
				, DiagnosisCode
				, IcdVersion
				, InjuryNatureId
				,ROW_NUMBER() OVER (PARTITION BY OdsCustomerId, DiagnosisCode, IcdVersion ORDER BY EndDate DESC) rnk
		    FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'IcdDiagnosisCodeDictionary' ELSE 'if_IcdDiagnosisCodeDictionary(@RunPostingGroupAuditId)' END + 
                     CASE WHEN @OdsCustomerId <> 0 THEN ' WHERE OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3))  ELSE '' END + '
		) X WHERE rnk = 1) dict
    ON dx.OdsCustomerId = dict.OdsCustomerId
    AND dx.DiagnosisCode = dict.DiagnosisCode
    AND dx.IcdVersion = dict.IcdVersion
LEFT JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'InjuryNature' ELSE 'if_InjuryNature(@RunPostingGroupAuditId)' END + ' I 
    ON dict.OdsCustomerId = I.OdsCustomerId
    AND dict.InjuryNatureId = I.InjuryNatureId
) X WHERE rnk = 1;


CREATE NONCLUSTERED INDEX nidx_CustIdCmtIDNo ON #InjuryNature
(OdsCustomerId,CmtIDNo) INCLUDE (Duration,InjuryNatureId,InjuryNatureDesc)

--5)Insert Results

IF OBJECT_ID(''tempdb..#temp'') IS NOT NULL DROP TABLE #temp;    
SELECT BH.OdsCustomerId,
      D.CustomerName AS CustomerName,
      CL.ClaimIDNo,
	  CL.ClaimNo,
      CM.CmtIDNo,
	  BH.BillIDNo,
	  B.LINE_NO,
	  CL.CV_Code,
	  CV.LongName CoverageTypeDesc,
	  Z.County,
      CM.CmtStateOfJurisdiction SOJ,
	  ISNULL(Co.CompanyName,''Unknown'') CompanyName,
	  ISNULL(O.OfcName,''Unknown'') OfcName,
	  AD.FirstName as AdjustorFirstName,
	  AD.Lastname as AdjustorLastName,
	  CL.DateLoss,
	  CASE WHEN B.EndDateOfService > B.DateOfService THEN B.EndDateOfService
                                      ELSE B.DateOfService END DOS,
      dx.InjuryNatureId,
	  ISNULL(dx.InjuryNatureDesc,''UNKNOWN'') InjuryNatureDesc,
	  ISNULL(dx.Duration,0) AS ERDDuration_Weeks,
	  ISNULL(dx.Duration,0)*7 AS ERDDuration_Days,
      B.ALLOWED,
	  B.CHARGED
into #temp	 
FROM #BILL_HDR BH
INNER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CLAIMANT' ELSE 'if_CLAIMANT(@RunPostingGroupAuditId)' END + ' CM  
    ON BH.OdsCustomerId = CM.OdsCustomerId
    AND BH.CmtIDNo = CM.CmtIDNo
INNER JOIN #CLAIMS CL 
	ON  CM.OdsCustomerId = CL.OdsCustomerId
	AND CM.ClaimIDNo  = CL.ClaimIDNo
	AND CL.ClaimNo NOT LIKE ''%TEST%''
	AND(CL.OdsCustomerId NOT IN (70,71) OR CL.Status <> ''C'')
INNER JOIN (
	SELECT 
	     OdsCustomerID,
		BillIDNo,
		LINE_NO,
		DT_SVC AS DateOfService,
		EndDateOfService,
		ISNULL(PreApportionedAmount,Allowed) AS Allowed,
		Charged
	FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'bills' ELSE 'if_bills(@RunPostingGroupAuditId)' END +
	CASE WHEN @OdsCustomerId <> 0 THEN ' WHERE OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3))  ELSE '' END + '  
	
	UNION ALL
	
	SELECT 
	     OdsCustomerID,
		BillIDNo,
		LINE_NO,
		DateOfService,
		EndDateOfService,
		ISNULL(PreApportionedAmount,Allowed) AS Allowed,
		Charged
	FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'bills_pharm' ELSE 'if_bills_pharm(@RunPostingGroupAuditId)' END +
	CASE WHEN @OdsCustomerId <> 0 THEN ' WHERE OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3))  ELSE '' END + '
	) B 
	
	ON  B.OdsCustomerID = BH.OdsCustomerID
     AND B.BillIDNo = BH.BillIDNo
INNER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'prf_COMPANY' ELSE 'if_prf_COMPANY(@RunPostingGroupAuditId)' END + ' CO 
	ON CO.OdsCustomerId = CL.OdsCustomerId
	AND CO.CompanyID = CL.CompanyID
	AND CO.CompanyName NOT LIKE ''%TEST%''
	AND CO.CompanyName NOT LIKE ''%TRAIN%''
INNER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'prf_Office' ELSE 'if_prf_Office(@RunPostingGroupAuditId)' END + ' O
    ON CL.OdsCustomerId = O.OdsCustomerId
    AND CL.OfficeIndex = O.OfficeId
LEFT JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'Adjustor' ELSE 'if_Adjustor(@RunPostingGroupAuditId)' END + ' AD
    ON CL.OdsCustomerId = AD.OdsCustomerId
    AND CL.AdjIdNo = AD.lAdjIdNo
LEFT JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CoverageType' ELSE 'if_CoverageType(@RunPostingGroupAuditId)' END + ' CV
    ON CL.OdsCustomerId = CV.OdsCustomerId
    AND CL.CV_Code = CV.ShortName
LEFT JOIN '+@SourceDatabaseName+'.adm.Customer D
	ON BH.OdsCustomerId = D.CustomerId
LEFT JOIN (
	 SELECT OdsCustomerId,ZipCode,County
	 FROM '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'ZipCode' ELSE 'if_ZipCode(@RunPostingGroupAuditId)' END + ' 
	 WHERE PrimaryRecord = 1 ) Z
	 ON  CM.OdsCustomerId = Z.OdsCustomerId
	 AND LEFT(CM.CmtZip,5) = Z.Zipcode  
LEFT JOIN #InjuryNature dx
    ON  dx.OdsCustomerID = CM.ODSCustomerID
    AND dx.CmtIDNo = CM.CmtIDNo' +
CASE WHEN @OdsCustomerId <> 0 THEN ' WHERE BH.OdsCustomerId  = '+CAST(@OdsCustomerId AS VARCHAR(3))  ELSE '' END + '

;WITH BeforeERD 
AS
(
SELECT OdsCustomerId
	,CmtIDNo
	,SUM(Allowed) AllowedBeforeERD
	,SUM(Charged) ChargedBeforeERD
FROM #temp
WHERE DOS <= DATEADD(dd,ERDDuration_Days,DateLoss) 
GROUP BY OdsCustomerId,CmtIDNo
)
,AfterERD
AS
(
SELECT OdsCustomerId
	,CmtIDNo
	,SUM(Allowed) AllowedAfterERD
	,SUM(Charged) ChargedAfterERD
FROM #temp
WHERE DOS > DATEADD(dd,ERDDuration_Days,DateLoss) 
GROUP BY OdsCustomerId,CmtIDNo
)
INSERT INTO '+@TargetDatabaseName+'.dbo.ERDReport
SELECT
	  A.OdsCustomerId,
	  ''ERDReport'' AS ReportName,
      CustomerName,
      ClaimIDNo,
	  ClaimNo,
      A.CmtIDNo,
	  ISNULL(CV_Code,''NA'') CoverageType,
	  ISNULL(CoverageTypeDesc,''UNKNOWN'') CoverageTypeDesc,
	  CompanyName AS Company,
	  OfcName AS Office,	
	  ISNULL(SOJ,''UN'') SOJ,
	  ISNULL(County,''UNKNOWN'') County,
	  ISNULL(AdjustorFirstName,''UNKNOWN'') AdjustorFirstName,
	  ISNULL(AdjustorLastName,''UNKNOWN'') AdjustorLastName,
	  Min(DateLoss) ClaimDateLoss,
	  MAX(DOS) DOS,
	  InjuryNatureId,
	  InjuryNatureDesc,
	  ERDDuration_Weeks,
	  ERDDuration_Days,
	  DATEDIFF(DD,Min(DateLoss),MAX(DOS)) AllowedTreatmentDuration_Days,
	  DATEDIFF(WW,Min(DateLoss),MAX(DOS)) AllowedTreatmentDuration_Weeks,
	  SUM(Charged) Charged,
	  SUM(Allowed) Allowed,
	  MAX(ISNULL(B.ChargedAfterERD,0)) ChargedAfterERD,
      MAX(ISNULL(B.AllowedAfterERD,0)) AllowedAfterERD,
	  GETDATE() Rundate	  
FROM #temp A
LEFT JOIN AfterERD B
ON A.OdsCustomerId = B.OdsCustomerId
AND A.CmtIDNo = B.CmtIDNo
GROUP BY
	  A.OdsCustomerId,
      CustomerName,
      ClaimIDNo,
	  ClaimNo,
      A.CmtIDNo,
	  ISNULL(CV_Code,''NA''),
	  ISNULL(CoverageTypeDesc,''UNKNOWN''),
	  ISNULL(SOJ,''UN''),
	  ISNULL(County,''UNKNOWN''),
	  ISNULL(AdjustorFirstName,''UNKNOWN''),
	  ISNULL(AdjustorLastName,''UNKNOWN''),
      InjuryNatureId,
	  InjuryNatureDesc,
	  ERDDuration_Weeks,
	  ERDDuration_Days,
	  CompanyName,
	  OfcName'


EXEC(@SQLScript); 

END


GO
