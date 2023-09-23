IF OBJECT_ID('dbo.ETL_completionstatusdetail', 'V') IS NOT NULL
DROP VIEW dbo.ETL_completionstatusdetail
GO

CREATE VIEW dbo.ETL_completionstatusdetail
AS
-- Get Last complete Load Date for each customer
WITH cte_lastcompleteload AS(
SELECT   B.CustomerId
		,MAX(CAST(B.SnapshotDate AS DATETIME)) LastestCmpltLoadDate

FROM dbo.ETL_completionstatusbaseline B
INNER JOIN adm.Customer C
	ON B.CustomerId = C.CustomerId

WHERE IsFullLoadCompleted = 1
	AND CmpltOltpPostingGroupAuditId IS NOT NULL 
GROUP BY B.CustomerId),
-- Get The last snapshotdate audited
cte_lastsnapshotaudit AS(
SELECT   B.CustomerId
		,MAX(CAST(B.SnapshotDate AS DATETIME)) LastSnapshotAuditDate

FROM dbo.ETL_completionstatusbaseline B
INNER JOIN adm.Customer C
	ON B.CustomerId = C.CustomerId

WHERE IsFullLoadCompleted = 1
GROUP BY B.CustomerId
),
cte_failurereason AS(
SELECT B.SnapshotDate 
	  ,B.CustomerId
	  ,C.CustomerName
	  ,CASE WHEN ((InCmpltOltpPostingGroupAuditId IS NULL AND CAST(B.SnapshotDate AS DATETIME) < L.LastestCmpltLoadDate) OR (InCmpltOltpPostingGroupAuditId IS NULL AND CAST(B.SnapshotDate AS DATETIME) > L.LastestCmpltLoadDate AND ISNULL(S.Status,'') <> 'S')) AND C.IsLoadedDaily = 1 THEN 1 ELSE 0 END AS OLTPFilesNotCreated
	  ,CASE WHEN ((InCmpltOltpPostingGroupAuditId IS NOT NULL AND CAST(B.SnapshotDate AS DATETIME) < L.LastestCmpltLoadDate) OR (InCmpltOltpPostingGroupAuditId IS NOT NULL AND CAST(B.SnapshotDate AS DATETIME) > L.LastestCmpltLoadDate AND ISNULL(S.Status,'') <> 'S')) AND C.IsLoadedDaily = 1 THEN 1 ELSE 0 END AS ODSLoadFailure
	  ,CASE WHEN InCmpltOltpPostingGroupAuditId IS NULL AND CAST(B.SnapshotDate AS DATETIME) > L.LastestCmpltLoadDate AND ISNULL(S.Status,'') = 'S' AND CAST(B.SnapshotDate AS DATETIME) >= A.LastSnapshotAuditDate  THEN 1 ELSE 0 END AS OLTPFilesqueued
	  ,CASE WHEN InCmpltOltpPostingGroupAuditId IS NOT NULL AND CAST(B.SnapshotDate AS DATETIME) > L.LastestCmpltLoadDate AND ISNULL(S.Status,'') = 'S' AND CAST(B.SnapshotDate AS DATETIME) >= A.LastSnapshotAuditDate THEN 1 ELSE 0 END AS ODSLoadInProgress
FROM dbo.ETL_completionstatusbaseline B
INNER JOIN adm.Customer C
	ON B.CustomerId = C.CustomerId
LEFT OUTER JOIN cte_lastcompleteload L
	ON B.CustomerId = L.CustomerId
LEFT OUTER JOIN cte_lastsnapshotaudit A
	ON B.CustomerId = A.CustomerId
CROSS APPLY (SELECT TOP 1 Status FROM adm.LoadStatus ORDER BY JobRunId DESC) S
	
WHERE IsFullLoadCompleted = 1
	AND CmpltOltpPostingGroupAuditId IS NULL 
)
SELECT 
	 F1.SnapshotDate
	,LTRIM(STUFF((SELECT ', ' + RTRIM(CONVERT(VARCHAR(100),CustomerName))
        FROM   cte_failurereason F2
        WHERE  F1.SnapshotDate = F2.SnapshotDate
        AND F2.OLTPFilesNotCreated = 1
        FOR XML PATH('')),1,1,'')) OLTPFilesNotCreated
    ,LTRIM(STUFF((SELECT ', ' + RTRIM(CONVERT(VARCHAR(100),CustomerName))
        FROM   cte_failurereason F2
        WHERE  F1.SnapshotDate = F2.SnapshotDate
        AND F2.ODSLoadFailure = 1
        FOR XML PATH('')),1,1,'')) ODSLoadFailure
	,LTRIM(STUFF((SELECT ', ' + RTRIM(CONVERT(VARCHAR(100),CustomerName))
        FROM   cte_failurereason F2
        WHERE  F1.SnapshotDate = F2.SnapshotDate
        AND F2.OLTPFilesqueued = 1
        FOR XML PATH('')),1,1,'')) OLTPFilesqueued
    ,LTRIM(STUFF((SELECT ', ' + RTRIM(CONVERT(VARCHAR(100),CustomerName))
        FROM   cte_failurereason F2
        WHERE  F1.SnapshotDate = F2.SnapshotDate
        AND F2.ODSLoadInProgress = 1
        FOR XML PATH('')),1,1,'')) ODSLoadInProgress
FROM cte_failurereason F1
GROUP BY F1.SnapshotDate


GO
