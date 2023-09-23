IF OBJECT_ID('dbo.ETL_customerdetail', 'V') IS NOT NULL
DROP VIEW dbo.ETL_customerdetail
GO

CREATE VIEW dbo.ETL_customerdetail
AS
WITH cte_NoRecordsLoaded AS(
SELECT PGA.CustomerId
	,PA.ProcessId
	,CONVERT(VARCHAR(10),LoadDate,101) AS LoadDate
	,SUM(CAST(PA.LoadRowCount AS BIGINT)-(CAST(PA.UpdateRowCount AS BIGINT)-CAST(PA.LoadRowCount As BIGINT))) AS NoOfLoadedRecords
FROM adm.ProcessAudit PA 
INNER JOIN adm.PostingGroupAudit PGA
ON PA.PostingGroupAuditId = PGA.PostingGroupAuditId
WHERE PA.Status = 'FI'
	AND PGA.Status = 'FI'
	AND PGA.DataExtractTypeId = 1
GROUP BY PGA.CustomerId
	,PA.ProcessId
	,CONVERT(VARCHAR(10),LoadDate,101))

SELECT PGA.CustomerId
  ,C.CustomerName
  ,MAX(CAST(I.LoadDate AS DATE)) LastIncrementalLoadDate
  ,MAX(CONVERT(VARCHAR(10),PA.LoadDate,101)) LastFullLoadDate
  ,P.TargetTableName
  ,PA.LoadRowCount AS TotalFullLoadRecords
  ,SUM(I.NoOfLoadedRecords) AS TotalNoOfLoadedRecords
      
FROM adm.ProcessAudit PA 
INNER JOIN adm.PostingGroupAudit PGA
ON PA.PostingGroupAuditId = PGA.PostingGroupAuditId
INNER JOIN cte_NoRecordsLoaded I
	ON PGA.CustomerId = I.CustomerId
	AND PA.ProcessId = I.ProcessId
	INNER JOIN adm.Process P
	ON P.ProcessId = PA.ProcessId
INNER JOIN adm.Customer C
ON C.CustomerId = PGA.CustomerId	
WHERE PA.Status = 'FI'
      AND PGA.Status = 'FI'
      AND PGA.DataExtractTypeId = 0
GROUP BY PGA.CustomerId
  ,C.CustomerName
  ,P.TargetTableName
  ,PA.LoadRowCount

GO


