
/*
Details:

Job Name : 'RPT: Provider Data Explorer'
Source Environment : AcsOds
Target Environment : ReportDb

*/

-- Verify the data in source(ODS)

SELECT COUNT(*) OdsCLAIMSCount from AcsOds.dbo.CLAIMS
SELECT COUNT(*) OdsClaimnatCount from AcsOds.dbo.CLAIMANT
SELECT COUNT(*) OdsclaimantHeaferCount from AcsOds.dbo.CMT_HDR
SELECT COUNT(*) OdsProviderCount from AcsOds.dbo.PROVIDER
SELECT COUNT(*) OdsBillHeaderCount from AcsOds.dbo.BILL_HDR
SELECT COUNT(*) OdsBillCount from AcsOds.dbo.BILLS
SELECT COUNT(*) OdsBillCount from AcsOds.dbo.BILLS_Endnotes
SELECT COUNT(*) OdsPharmBillCount from AcsOds.dbo.Bills_Pharm
SELECT COUNT(*) OdsProviderClusterCount from AcsOds.dbo.ProviderCluster


GO


-- Check weather data is papulated or not 

SELECT COUNT(*) AS TotalCount FROM dbo.ProviderDataExplorerClaimantHeader
SELECT COUNT(*) AS TotalCount FROM dbo.ProviderDataExplorerProvider
SELECT COUNT(*) AS TotalCount FROM dbo.ProviderDataExplorerBillHeader
SELECT COUNT(*) AS TotalCount FROM dbo.ProviderDataExplorerBillLine


GO

-- Validate the Customer wise record count for subscribed customers

SELECT s.CustomerId, 
	   COUNT(b.OdsCustomerId) AS TotalCount 
FROM rpt.CustomerReportSubscription s 
LEFT JOIN dbo.ProviderDataExplorerBillLine b ON b.OdsCustomerId = s.CustomerId  
											AND s.IsActive = 1
GROUP BY s.CustomerId


GO


-- Validate the record count for dbo.ProviderDataExplorerClaimantHeader against the source database

DECLARE @StartDate DATE 
DECLARE @Enddate DATE
DECLARE @OdsCustomerId INT = 6
SELECT @StartDate = ParameterValue FROM adm.ReportParameters WHERE ReportId = 9 AND ParameterName = 'ODSPAStartDate'
SELECT @Enddate	= DATEADD(MONTH,DATEDIFF(MONTH,-1,DATEADD(mm,27,@StartDate))-1,-1)

SELECT COUNT(*) AcsodsClaimentHeader 
FROM AcsOds.dbo.CLAIMS c 
  INNER JOIN AcsOds.dbo.CLAIMANT cmt ON c.OdsCustomerId = cmt.OdsCustomerId 
             AND c.ClaimIDNo=cmt.ClaimIDNo
  INNER JOIN AcsOds.dbo.CMT_HDR ch ON ch.OdsCustomerId = cmt.OdsCustomerId 
             AND ch.CmtIDNo=cmt.CmtIDNo
WHERE c.DateLoss BETWEEN @StartDate AND @Enddate	
	AND c.OdsCustomerId = @OdsCustomerId;

SELECT COUNT(*) PAClaimentHeaderCount 
FROM dbo.ProviderDataExplorerClaimantHeader 
WHERE OdsCustomerId = @OdsCustomerId 
	AND DateLoss BETWEEN @StartDate AND @Enddate;


GO


-- Validate record count for dbo.ProviderDataExplorerProvider against the source database

DECLARE @StartDate DATE 
DECLARE @Enddate DATE
DECLARE @OdsCustomerId INT = 6
SELECT @StartDate = ParameterValue FROM adm.ReportParameters WHERE ReportId = 9 AND ParameterName = 'ODSPAStartDate'
SELECT @Enddate	= DATEADD(MONTH,DATEDIFF(MONTH,-1,DATEADD(mm,27,@StartDate))-1,-1)

SELECT COUNT(*) AcsOdsProviderCount 
FROM (
  SELECT DISTINCT c.OdsCustomerId,p.pvdidno
  FROM AcsOds.dbo.CLAIMS c 
  INNER JOIN AcsOds.dbo.CLAIMANT cmt ON c.OdsCustomerId = cmt.OdsCustomerId 
             AND c.ClaimIDNo = cmt.ClaimIDNo
  INNER JOIN AcsOds.dbo.CMT_HDR ch ON ch.OdsCustomerId = cmt.OdsCustomerId 
             AND ch.CmtIDNo = cmt.CmtIDNo
  INNER JOIN AcsOds.dbo.PROVIDER p ON p.OdsCustomerId = ch.OdsCustomerId 
                AND p.PvdIDNo = ch.PvdIDNo 
  WHERE c.DateLoss BETWEEN @StartDate AND @Enddate
  AND c.OdsCustomerId = @OdsCustomerId
 ) a;

SELECT COUNT(DISTINCT P.ProviderId) PAProviderCount
FROM dbo.ProviderDataExplorerClaimantHeader C 
INNER JOIN dbo.ProviderDataExplorerProvider P ON C.OdsCustomerId = p.OdsCustomerId
			AND c.ProviderId = p.ProviderId
WHERE c.OdsCustomerId = @OdsCustomerId
	AND DateLoss BETWEEN @StartDate AND @Enddate;


GO


--Validate the record count for dbo.ProviderDataExplorerBillHeader against the source database

DECLARE @StartDate DATE 
DECLARE @Enddate DATE
DECLARE @OdsCustomerId INT = 6
SELECT @StartDate = ParameterValue FROM adm.ReportParameters WHERE ReportId = 9 AND ParameterName = 'ODSPAStartDate'
SELECT @Enddate	= DATEADD(MONTH,DATEDIFF(MONTH,-1,DATEADD(mm,27,@StartDate))-1,-1)

SELECT COUNT(*) AcsodsBillHeaderCount
FROM AcsOds.dbo.CLAIMS c 
  INNER JOIN AcsOds.dbo.CLAIMANT cmt ON c.OdsCustomerId = cmt.OdsCustomerId 
             AND c.ClaimIDNo = cmt.ClaimIDNo
  INNER JOIN AcsOds.dbo.CMT_HDR ch ON ch.OdsCustomerId = cmt.OdsCustomerId 
             AND ch.CmtIDNo = cmt.CmtIDNo
  INNER JOIN AcsOds.dbo.BILL_HDR bh ON ch.OdsCustomerId = bh.OdsCustomerId 
             AND ch.CMT_HDR_IDNo = bh.CMT_HDR_IDNo
WHERE  c.DateLoss BETWEEN @StartDate AND @Enddate
	AND c.OdsCustomerId = @OdsCustomerId;

SELECT COUNT(*) PABillHeaderCount 
FROM dbo.ProviderDataExplorerClaimantHeader C 
INNER JOIN dbo.ProviderDataExplorerBillHeader bh ON C.OdsCustomerId = bh.OdsCustomerId
			AND c.ClaimantHeaderId = bh.ClaimantHeaderId
WHERE c.OdsCustomerId = @OdsCustomerId
	AND DateLoss BETWEEN @StartDate AND @Enddate;


GO


--Validate the record count for dbo.ProviderDataExplorerBillLine against the source database 

DECLARE @StartDate DATE 
DECLARE @Enddate DATE
DECLARE @OdsCustomerId INT = 6
SELECT @StartDate = ParameterValue FROM adm.ReportParameters WHERE ReportId = 9 AND ParameterName = 'ODSPAStartDate'
SELECT @Enddate	= DATEADD(MONTH,DATEDIFF(MONTH,-1,DATEADD(mm,27,@StartDate))-1,-1)

Select COUNT(*) AcsodsBillsCount 
FROM (
SELECT b.OdsCustomerId,
    b.BillIDNo,
    b.LINE_NO 
 FROM AcsOds.dbo.CLAIMS c 
  INNER JOIN AcsOds.dbo.CLAIMANT cmt ON c.OdsCustomerId = cmt.OdsCustomerId 
            AND c.ClaimIDNo = cmt.ClaimIDNo
  INNER JOIN AcsOds.dbo.CMT_HDR ch ON ch.OdsCustomerId = cmt.OdsCustomerId 
            AND ch.CmtIDNo = cmt.CmtIDNo
  INNER JOIN AcsOds.dbo.BILL_HDR bh ON bh.OdsCustomerId = ch.OdsCustomerId 
            AND ch.CMT_HDR_IDNo = bh.CMT_HDR_IDNo
  INNER JOIN AcsOds.dbo.BILLs b ON b.OdsCustomerId = bh.OdsCustomerId 
            AND b.BillIDNo = bh.BillIDNo
WHERE c.DateLoss BETWEEN @StartDate AND @Enddate
  AND c.OdsCustomerId = @OdsCustomerId
  AND NOT EXISTS(
    SELECT 1 FROM AcsOds.dbo.BILLS_Endnotes be 
      WHERE b.OdsCustomerId = be.OdsCustomerId 
      AND b.BillIDNo = be.BillIDNo 
      AND b.line_no = be.LINE_NO
      AND EndNote IN(10,35,45)
    ) AND  PRC_CD <> 'COORD'

UNION ALL
SELECT b.OdsCustomerId,
    b.BillIDNo,
    b.LINE_NO 
 FROM AcsOds.dbo.CLAIMS c 
  INNER JOIN AcsOds.dbo.CLAIMANT cmt ON c.OdsCustomerId = cmt.OdsCustomerId 
            AND c.ClaimIDNo = cmt.ClaimIDNo
  INNER JOIN AcsOds.dbo.CMT_HDR ch ON ch.OdsCustomerId = cmt.OdsCustomerId 
            AND ch.CmtIDNo = cmt.CmtIDNo
  INNER JOIN AcsOds.dbo.BILL_HDR bh ON bh.OdsCustomerId = ch.OdsCustomerId 
            AND ch.CMT_HDR_IDNo = bh.CMT_HDR_IDNo
  INNER JOIN AcsOds.dbo.Bills_Pharm b ON b.OdsCustomerId = bh.OdsCustomerId 
             AND b.BillIDNo = bh.BillIDNo
WHERE c.DateLoss BETWEEN @StartDate AND @Enddate
  AND c.OdsCustomerId = @OdsCustomerId
  AND NOT EXISTS(
      SELECT 1 FROM AcsOds.dbo.BILLS_Endnotes be 
      WHERE b.OdsCustomerId = be.OdsCustomerId 
      AND b.BillIDNo = be.BillIDNo 
      AND b.LINE_NO = be.LINE_NO
      AND EndNote IN(10,35,45) ) 
) a ;

SELECT COUNT(*) PABillsCount 
FROM dbo.ProviderDataExplorerClaimantHeader C 
INNER JOIN dbo.ProviderDataExplorerBillHeader bh ON C.OdsCustomerId = bh.OdsCustomerId
											AND c.ClaimantHeaderId = bh.ClaimantHeaderId
INNER JOIN dbo.ProviderDataExplorerBillLine bl ON bl.OdsCustomerId =  bh.OdsCustomerId
											AND bl.BillId = bh.BillId
WHERE c.OdsCustomerId = @OdsCustomerId
	AND DateLoss BETWEEN @StartDate AND @Enddate
	AND ISNULL(BundlingFlag,0) <> 1;


GO


----Validate the sum charged and sum allowed values for dbo.ProviderDataExplorerBillLine against the source 

DECLARE @StartDate DATE 
DECLARE @Enddate DATE
DECLARE @OdsCustomerId INT = 6
SELECT @StartDate = ParameterValue FROM adm.ReportParameters WHERE ReportId = 9 AND ParameterName = 'ODSPAStartDate'
SELECT @Enddate	= DATEADD(MONTH,DATEDIFF(MONTH,-1,DATEADD(mm,27,@StartDate))-1,-1)

Select SUM(CHARGED) AS TotalCharged,SUM(ALLOWED) AS TotalAllowed
FROM (
SELECT b.OdsCustomerId,
    b.BillIDNo,
    b.LINE_NO ,
    b.CHARGED,
    b.ALLOWED

 FROM AcsOds.dbo.CLAIMS c 
  INNER JOIN AcsOds.dbo.CLAIMANT cmt ON c.OdsCustomerId = cmt.OdsCustomerId 
            AND c.ClaimIDNo = cmt.ClaimIDNo
  INNER JOIN AcsOds.dbo.CMT_HDR ch ON ch.OdsCustomerId = cmt.OdsCustomerId 
            AND ch.CmtIDNo = cmt.CmtIDNo
  INNER JOIN AcsOds.dbo.BILL_HDR bh ON bh.OdsCustomerId = ch.OdsCustomerId 
            AND ch.CMT_HDR_IDNo = bh.CMT_HDR_IDNo
  INNER JOIN AcsOds.dbo.BILLs b ON b.OdsCustomerId = bh.OdsCustomerId 
            AND b.BillIDNo = bh.BillIDNo
WHERE c.DateLoss BETWEEN @StartDate AND @Enddate
  AND c.OdsCustomerId = @OdsCustomerId
  AND NOT EXISTS(
    SELECT 1 FROM AcsOds.dbo.BILLS_Endnotes be 
      WHERE b.OdsCustomerId = be.OdsCustomerId 
      AND b.BillIDNo = be.BillIDNo 
      AND b.line_no = be.LINE_NO
      AND EndNote IN(10,35,45)
    ) AND  PRC_CD <> 'COORD'

UNION ALL
SELECT b.OdsCustomerId,
    b.BillIDNo,
    b.LINE_NO ,
    b.CHARGED,
    b.ALLOWED
 FROM AcsOds.dbo.CLAIMS c 
  INNER JOIN AcsOds.dbo.CLAIMANT cmt ON c.OdsCustomerId = cmt.OdsCustomerId 
            AND c.ClaimIDNo = cmt.ClaimIDNo
  INNER JOIN AcsOds.dbo.CMT_HDR ch ON ch.OdsCustomerId = cmt.OdsCustomerId 
            AND ch.CmtIDNo = cmt.CmtIDNo
  INNER JOIN AcsOds.dbo.BILL_HDR bh ON bh.OdsCustomerId = ch.OdsCustomerId 
            AND ch.CMT_HDR_IDNo = bh.CMT_HDR_IDNo
  INNER JOIN AcsOds.dbo.Bills_Pharm b ON b.OdsCustomerId = bh.OdsCustomerId 
             AND b.BillIDNo = bh.BillIDNo
WHERE c.DateLoss BETWEEN @StartDate AND @Enddate
  AND c.OdsCustomerId = @OdsCustomerId
  AND NOT EXISTS(
      SELECT 1 FROM AcsOds.dbo.BILLS_Endnotes be 
      WHERE b.OdsCustomerId = be.OdsCustomerId 
      AND b.BillIDNo = be.BillIDNo 
      AND b.LINE_NO = be.LINE_NO
      AND EndNote IN(10,35,45) ) 
) a ;

 
SELECT SUM(CHARGED) AS PATotalCharged,SUM(ALLOWED) AS PATotalAllowed
FROM dbo.ProviderDataExplorerClaimantHeader C 
INNER JOIN dbo.ProviderDataExplorerBillHeader bh ON C.OdsCustomerId = bh.OdsCustomerId
										AND c.ClaimantHeaderId = bh.ClaimantHeaderId
INNER JOIN dbo.ProviderDataExplorerBillLine bl ON bl.OdsCustomerId =  bh.OdsCustomerId
										AND bl.BillId = bh.BillId
WHERE c.OdsCustomerId = @OdsCustomerId
	AND DateLoss BETWEEN @StartDate AND @Enddate
	AND ISNULL(BundlingFlag,0) <> 1;


GO


---Validate the record count of provider Clusters against the source database 

DECLARE @StartDate DATE 
DECLARE @Enddate DATE
DECLARE @OdsCustomerId INT = 6
SELECT @StartDate = ParameterValue FROM adm.ReportParameters WHERE ReportId = 9 AND ParameterName = 'ODSPAStartDate'
SELECT @Enddate	= DATEADD(MONTH,DATEDIFF(MONTH,-1,DATEADD(mm,27,@StartDate))-1,-1)

SELECT 
COUNT(DISTINCT Pc.ProviderClusterKey) ProviderclusterCount
 FROM AcsOds.dbo.CLAIMS c 
  INNER JOIN AcsOds.dbo.CLAIMANT cmt ON c.OdsCustomerId = cmt.OdsCustomerId 
            AND c.ClaimIDNo = cmt.ClaimIDNo
  INNER JOIN AcsOds.dbo.CMT_HDR ch ON ch.OdsCustomerId = cmt.OdsCustomerId 
            AND ch.CmtIDNo = cmt.CmtIDNo
  INNER JOIN AcsOds.dbo.PROVIDER p ON p.OdsCustomerId = ch.OdsCustomerId 
            AND P.PvdIDNo = Ch.PvdIDNo
  INNER JOIN AcsOds.dbo.ProviderCluster pc ON p.OdsCustomerId = pc.OrgOdsCustomerId 
            AND P.PvdIDNo = pc.PvdIDNo
WHERE c.DateLoss BETWEEN @StartDate AND @Enddate
	    AND c.OdsCustomerId = @OdsCustomerId;


SELECT COUNT(DISTINCT ProviderClusterId) ProviderclusterCount  
FROM dbo.ProviderDataExplorerClaimantHeader C 
INNER JOIN dbo.ProviderDataExplorerProvider P ON C.OdsCustomerId = p.OdsCustomerId
			AND c.ProviderId = p.ProviderId
WHERE c.OdsCustomerId = @OdsCustomerId
	AND DateLoss BETWEEN @StartDate AND @Enddate;


GO


--Validate record count of claimants for particular state of jurisdiction against the source database

DECLARE @StartDate DATE 
DECLARE @Enddate DATE
DECLARE @OdsCustomerId INT = 6
SELECT @StartDate = ParameterValue FROM adm.ReportParameters WHERE ReportId = 9 AND ParameterName = 'ODSPAStartDate'
SELECT @Enddate	= DATEADD(MONTH,DATEDIFF(MONTH,-1,DATEADD(mm,27,@StartDate))-1,-1)


SELECT 
 COUNT(DISTINCT cmt.CmtIDNo) CountOfClaimants
 FROM AcsOds.dbo.CLAIMS c 
  INNER JOIN AcsOds.dbo.CLAIMANT cmt ON c.OdsCustomerId = cmt.OdsCustomerId 
            AND c.ClaimIDNo = cmt.ClaimIDNo
  INNER JOIN AcsOds.dbo.CMT_HDR ch ON ch.OdsCustomerId = cmt.OdsCustomerId 
            AND ch.CmtIDNo = cmt.CmtIDNo
WHERE  c.DateLoss BETWEEN @StartDate AND @Enddate
  AND c.OdsCustomerId = @OdsCustomerId
  AND cmt.CmtStateOfJurisdiction = 'NY';


SELECT COUNT(DISTINCT ClaimantId) CountOfClaimants  
FROM dbo.ProviderDataExplorerClaimantHeader
WHERE OdsCustomerId = @OdsCustomerId  
	AND ClaimantStateofJurisdiction = 'NY'
	AND DateLoss BETWEEN @StartDate AND @Enddate;


GO


--Calculate the job execution Time with Customer wise.
SELECT AuditFor,CONVERT(VARCHAR(5),DATEDIFF(s, MIN(startdatetime), MAX(EndDatetime))/3600)+':'+
	   CONVERT(VARCHAR(5),DATEDIFF(s, MIN(startdatetime), MAX(EndDatetime))%3600/60)+':'+
	   CONVERT(VARCHAR(5),(DATEDIFF(s, MIN(startdatetime), MAX(EndDatetime))%60)) AS [hh:mm:ss]
	   FROM ProviderDataExplorerEtlAudit 
WHERE AuditId >= CASE WHEN 
(SELECT COUNT(*) 
	FROM dbo.ProviderDataExplorerEtlAudit 
	WHERE LTRIM(RTRIM(AUDITFOR)) = 'OdsCustomerId : 0' ) > 1 
THEN
(SELECT MIN(AuditId)+1 FROM 
	(SELECT TOP 2 AuditId 
	FROM dbo.ProviderDataExplorerEtlAudit
	 WHERE LTRIM(RTRIM(AuditFor))= 'OdsCustomerId : 0' 
	 ORDER BY 1 DESC)a 
 )

ELSE 
(SELECT Min(AuditID) FROM dbo.ProviderDataExplorerEtlAudit)

END
GROUP BY AuditFor
ORDER BY 1 DESC


GO


--Calculate the job execution Time for all customer .
-- Total Time duration
SELECT CONVERT(VARCHAR(5),DATEDIFF(s, MIN(startdatetime), MAX(EndDatetime))/3600)+':'+
	   CONVERT(VARCHAR(5),DATEDIFF(s, MIN(startdatetime), MAX(EndDatetime))%3600/60)+':'+
	   CONVERT(VARCHAR(5),(DATEDIFF(s, MIN(startdatetime), MAX(EndDatetime))%60)) AS [hh:mm:ss]
	   FROM ProviderDataExplorerEtlAudit 
WHERE AuditId >= CASE WHEN 
(SELECT COUNT(*) 
	FROM dbo.ProviderDataExplorerEtlAudit 
	WHERE LTRIM(RTRIM(AUDITFOR)) = 'OdsCustomerId : 0' ) > 1 
THEN
(SELECT MIN(AuditId)+1 FROM 
	(SELECT TOP 2 AuditId 
	FROM dbo.ProviderDataExplorerEtlAudit
	 WHERE LTRIM(RTRIM(AuditFor))= 'OdsCustomerId : 0' 
	 ORDER BY 1 DESC)a 
	)

ELSE 
(SELECT Min(AuditID) FROM dbo.ProviderDataExplorerEtlAudit)

END


GO


--Check for Provider cluster name is populated or not

SELECT TOP 100 OdsCustomerId, ProviderId, ProviderClusterName 
FROM dbo.ProviderDataExplorerProvider


GO


--Verification for Calculated Fields

SELECT  DISTINCT TOP 100 OdsCustomerId,BillID,FormType,SubFormType,BillInjuryDescription 
FROM dbo.ProviderDataExplorerBillLine


GO


