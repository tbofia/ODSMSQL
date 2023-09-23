IF OBJECT_ID('adm.Etl_QueuePostingGroupForArchive', 'P') IS NOT NULL
    DROP PROCEDURE adm.Etl_QueuePostingGroupForArchive
GO

CREATE PROCEDURE adm.Etl_QueuePostingGroupForArchive (
@CustomerId INT ,
@SnapshotDate VARCHAR(50),
@DataExtractTypeId INT)
AS
BEGIN
-- DECLARE @CustomerId INT = 1,		@SnapshotDate VARCHAR(50)='1900-10-01',	@DataExtractTypeId INT=0;

WITH cte_FullLoadProcesses AS(
-- Processes that have completed the full load
SELECT DISTINCT PA.ProcessId, P.TargetTableName
FROM adm.Process P
INNER JOIN adm.ProcessAudit PA ON P.ProcessId = PA.ProcessId
INNER JOIN adm.PostingGroupAudit PGA 
	ON PA.PostingGroupAuditId = PGA.PostingGroupAuditId
	AND PGA.CustomerId = @CustomerId
	AND PGA.DataExtractTypeId = 0
WHERE PA.Status = 'FI')

-- Update the Posting Group As Ready for archiving if all the processes are done.
UPDATE PGA 
SET  PGA.Status = 'A'
 ,PGA.LastChangeDate = GETDATE()
 
FROM adm.PostingGroupAudit PGA
INNER JOIN (
	-- Incrementals and Snapshots
	SELECT  PGA.PostingGroupAuditId
	FROM stg.ETL_ControlFiles F 
	INNER JOIN adm.PostingGroupAudit PGA 
		ON PGA.SnapshotCreateDate = F.SnapshotDate
		AND PGA.CustomerId = @CustomerId
	INNER JOIN adm.Process P 
		ON P.TargetTableName = F.TargetTableName
		AND P.IsActive = 1
	LEFT OUTER JOIN adm.ProcessAudit PA
	ON PA.ProcessId = P.ProcessId
	AND PA.PostingGroupAuditId = PGA.PostingGroupAuditId
	AND PA.Status = 'FI'
	WHERE F.SnapshotDate = @SnapshotDate 
		AND @DataExtractTypeId IN (1,2)
	GROUP BY PGA.PostingGroupAuditId
	HAVING COUNT(1) = SUM(CASE WHEN PA.ProcessId IS NOT NULL THEN 1 ELSE 0 END)
	
	UNION 
	-- FullLoads (Also applies when new tables are added.)
	SELECT PGA.PostingGroupAuditId
	FROM stg.ETL_ControlFiles C
	INNER JOIN adm.PostingGroupAudit PGA 
		ON PGA.SnapshotCreateDate = C.SnapshotDate
		AND PGA.CustomerId = @CustomerId 
	LEFT OUTER JOIN cte_FullLoadProcesses F ON C.TargetTableName = F.TargetTableName
	WHERE C.SnapshotDate = @SnapshotDate
		AND @DataExtractTypeId = 0
	GROUP BY PGA.PostingGroupAuditId
	HAVING COUNT(1) = SUM(CASE WHEN F.ProcessId IS NOT NULL THEN 1 ELSE 0 END)) F 

ON PGA.PostingGroupAuditId = F.PostingGroupAuditId
WHERE PGA.Status <> 'FI';

END

GO
