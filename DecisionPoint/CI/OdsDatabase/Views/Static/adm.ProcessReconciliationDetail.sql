IF OBJECT_ID('adm.ProcessReconciliationDetail', 'V') IS NOT NULL
DROP VIEW adm.ProcessReconciliationDetail
GO

CREATE VIEW adm.ProcessReconciliationDetail AS
WITH LAST_SS AS(
SELECT CustomerId
       ,MAX(PostingGroupAuditId) PostingGroupAuditId 
FROM adm.PostingGroupAudit 
WHERE DataExtracttypeId IN (0,2)
GROUP BY CustomerId
)

SELECT 
	 C.CustomerName
	,C.CustomerDatabase
	,C.ServerName
	,PR.ProcessId
	,P.TargetTableName
	,CASE WHEN PA.TotalRecordsInSource = 0 THEN 'Y' ELSE 'N' END AS RowCountReportedAsZeroInSource
	,MIN(PGA.SnapshotCreateDate) SnapshotCreateDate       
	,MIN(PGA.PostingGroupAuditId) PostingGroupAuditId
FROM adm.ProcessReconciliation PR
INNER JOIN adm.Customer C ON C.CustomerId = PR.CustomerId
INNER JOIN adm.PostingGroupAudit PGA ON PR.CustomerId = PGA.CustomerId
INNER JOIN LAST_SS SS ON PGA.CustomerId =SS.CustomerId 
       AND PGA.PostingGroupAuditId > SS.PostingGroupAuditId
INNER JOIN adm.ProcessAudit PA ON PGA.PostingGroupAuditId = PA.PostingGroupAuditId
       AND PR.ProcessId = PA.ProcessId
INNER JOIN adm.Process P
ON P.ProcessId = PA.ProcessId

WHERE PA.TotalRecordsInSource <> PA.TotalRecordsInTarget
AND PA.TotalRecordsInSource  IS NOT NULL
AND  PA.TotalRecordsInTarget IS NOT NULL
GROUP BY C.CustomerName
	,C.CustomerDatabase
	,C.ServerName
	,PR.ProcessId
	,P.TargetTableName
	,CASE WHEN PA.TotalRecordsInSource = 0 THEN 'Y' ELSE 'N' END


GO


