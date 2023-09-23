IF OBJECT_ID('dbo.ETL_completionstatusbaseline', 'V') IS NOT NULL
DROP VIEW dbo.ETL_completionstatusbaseline
GO

CREATE VIEW dbo.ETL_completionstatusbaseline
AS
-- Distinct dates on which ODS has bee loaded
WITH cte_dates AS(
SELECT DISTINCT CONVERT(VARCHAR(10),SnapshotCreateDate,101) SnapshotDate 
FROM adm.PostingGroupAudit)

-- Distinct Customers with dates on which Completed FullLoads
,cte_customers AS(
SELECT  DISTINCT CONVERT(VARCHAR(10),PGA.SnapshotCreateDate,101) SnapshotCreateDate
	,PGA.CustomerId
	,ROW_NUMBER() OVER(PARTITION BY PGA.CustomerId ORDER BY PGA.SnapshotCreateDate) R_Date -- We want to identify the first full load
FROM adm.PostingGroupAudit PGA
INNER JOIN adm.Customer C
ON PGA.CustomerId = C.CustomerId

WHERE PGA.DataExtractTypeId = 0
	AND C.IsActive = 1)
,cte_customerfullloadstatus AS(
SELECT 
	 D.SnapshotDate
	,C.CustomerId
	,CASE WHEN CAST(CD.SnapshotCreateDate AS DATE) <= CAST(D.SnapshotDate AS DATE) THEN 1 ELSE 0 END AS IsFullLoadCompleted
FROM cte_dates D 
CROSS APPLY (SELECT DISTINCT CustomerId FROM cte_customers) C
LEFT OUTER JOIN cte_customers CD ON C.CustomerId = CD.CustomerId
	AND CD.R_Date = 1)
SELECT DISTINCT C.SnapshotDate
	,C.CustomerId
	,C.IsFullLoadCompleted
	,PGA.OltpPostingGroupAuditId CmpltOltpPostingGroupAuditId
	,PGA2.OltpPostingGroupAuditId InCmpltOltpPostingGroupAuditId
FROM cte_customerfullloadstatus C
-- Completed Posting groups 
LEFT OUTER JOIN adm.PostingGroupAudit PGA
	ON C.CustomerId = PGA.CustomerId
	AND C.SnapshotDate = CONVERT(VARCHAR(10),PGA.SnapshotCreateDate,101)
	AND PGA.Status = 'FI'
-- Posting groups with failures
LEFT OUTER JOIN adm.PostingGroupAudit PGA2
	ON C.CustomerId = PGA2.CustomerId
	AND C.SnapshotDate = CONVERT(VARCHAR(10),PGA2.SnapshotCreateDate,101)
	AND PGA2.Status <> 'FI';



GO


