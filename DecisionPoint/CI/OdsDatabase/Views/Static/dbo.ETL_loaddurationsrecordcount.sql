IF OBJECT_ID('dbo.ETL_loaddurationsrecordcount', 'V') IS NOT NULL
DROP VIEW dbo.ETL_loaddurationsrecordcount
GO

CREATE VIEW dbo.ETL_loaddurationsrecordcount
AS
SELECT C.CustomerId
	  ,C.CustomerName
	  ,PGA.OltpPostingGroupAuditId
      ,CONVERT(VARCHAR(10),PGA.CreateDate,101) ETLLoadDate
      ,PGA.DataExtractTypeId AS IsIncremental
      ,CASE WHEN PGA.Status = 'FI' AND PA.Status  = 'FI' THEN 1 ELSE 0 END ETLCompletionStatus
      ,PA.ProcessId
      ,P.TargetTableName
      ,DATEDIFF(SS,PA.CreateDate,PA.LoadDate)	LoadTime
	  ,CAST(PA.LoadRowCount AS BIGINT)-(ISNULL(PA.UpdateRowCount,PA.LoadRowCount)-PA.LoadRowCount)	NoRecordsLoaded
	  
FROM adm.PostingGroupAudit PGA
INNER JOIN adm.Customer C
ON PGA.CustomerId = C.CustomerId
LEFT OUTER JOIN adm.PostingGroupAudit PGA2
	ON PGA.CustomerId = PGA2.CustomerId
	AND PGA.SnapshotCreateDate = PGA2.SnapshotCreateDate
	AND PGA2.Status = 'FI'
LEFT OUTER JOIN adm.ProcessAudit PA
	ON PA.PostingGroupAuditId = PGA.PostingGroupAuditId
	AND PA.Status = 'FI'
INNER JOIN adm.Process P
ON PA.ProcessId = P.ProcessId
WHERE (PGA.Status = 'FI' AND PGA2.Status = 'FI')
OR (PGA2.Status IS NULL)


GO


