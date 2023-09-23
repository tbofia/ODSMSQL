
IF OBJECT_ID('adm.Etl_GetPostingGroupAuditId', 'P') IS NOT NULL
    DROP PROCEDURE adm.Etl_GetPostingGroupAuditId
GO

CREATE PROCEDURE adm.Etl_GetPostingGroupAuditId (
@OltpPostingGroupAuditId INT,
@PostingGroupId INT,
@CustomerId INT,
@OdsVersion VARCHAR(20),
@CoreDBVersionId INT,
@SnapshotCreateDate VARCHAR(100),
@DataExtractTypeId INT)
AS
BEGIN
-- DECLARE @OltpPostingGroupAuditId INT = 1,@PostingGroupId INT = 1,@CustomerId INT = 1,@OdsVersion VARCHAR(20) = '1.0.0.0',@CoreDBVersionId INT = 0,@SnapshotCreateDate VARCHAR(100) = '1900-01-01',@DataExtractTypeId INT = 1 

DECLARE  @PostingGroupAuditId INT
		,@LastLoadStatus VARCHAR(2)
		,@SourceServer VARCHAR(255) = (SELECT ServerName FROM adm.Customer WHERE CustomerId = @CustomerId)
		,@FullLoadProcess VARCHAR(255)
		,@LatestCoreDBVersionId INT;

-- Get Latest CoreDBVersion for the Customers Server
SELECT @LatestCoreDBVersionId = MAX(PGA.CoreDBVersionId)
FROM adm.Customer C
INNER JOIN adm.PostingGroupAudit PGA
ON C.CustomerId = PGA.CustomerId
WHERE PGA.Status = 'FI'
	AND C.ServerName = @SourceServer;

-- Check for new tables in case of full load
WITH cte_FullLoadProcesses AS(
-- Processes that have completed the full load
SELECT PA.ProcessId, P.TargetTableName
FROM adm.Process P
INNER JOIN adm.ProcessAudit PA ON P.ProcessId = PA.ProcessId
INNER JOIN adm.PostingGroupAudit PGA 
	ON PA.PostingGroupAuditId = PGA.PostingGroupAuditId
	AND PGA.CustomerId = @CustomerId 
	AND PGA.DataExtractTypeId = 0
WHERE PA.Status = 'FI')
-- Check is any new tables are in this Full Load
SELECT TOP 1 @FullLoadProcess = C.ControlFileName
FROM stg.ETL_ControlFiles C
LEFT OUTER JOIN cte_FullLoadProcesses F ON C.TargetTableName = F.TargetTableName
WHERE C.OltpPostingGroupAuditId = @OltpPostingGroupAuditId AND C.SnapshotDate = @SnapshotCreateDate AND F.ProcessId IS NULL

-- Get Status of last posting group, only move forward if completed.
SELECT TOP 1 @LastLoadStatus = Status
FROM adm.PostingGroupAudit 
WHERE CustomerId = @CustomerId
ORDER BY PostingGroupAuditId DESC

-- If the Version at the Source is higher that the Ods Version then do not create any PostingGroupAuditId
IF (CAST('/' + REPLACE(@OdsVersion,'.','.1') + '/' AS HIERARCHYID) > (SELECT MAX(CAST('/' + REPLACE(AppVersion,'.','.1') + '/' AS HIERARCHYID)) FROM adm.AppVersion))
	SET @PostingGroupAuditId = 0
ELSE
	BEGIN 
	-- Check if PostingGroup Audit id has already been created.
	SELECT TOP 1 @PostingGroupAuditId  = PostingGroupAuditId 
	FROM adm.PostingGroupAudit 
	WHERE SnapshotCreateDate = @SnapshotCreateDate 
	AND CustomerId = @CustomerId

	-- Generate Postinggroupauditid if does not already exist.
	IF (@PostingGroupAuditId IS NULL 
	AND ((@DataExtractTypeId = 0 AND (@LastLoadStatus IS NULL OR (@FullLoadProcess IS NOT NULL AND @LastLoadStatus = 'FI')))
	  OR (@DataExtractTypeId IN (1,2) AND @LastLoadStatus = 'FI')))
		INSERT INTO adm.PostingGroupAudit( 
		   OltpPostingGroupAuditId
		  ,PostingGroupId
		  ,CustomerId
		  ,Status
		  ,DataExtractTypeId
		  ,OdsVersion
		  ,CoreDBVersionId
		  ,SnapshotCreateDate
		  ,CreateDate
		  ,LastChangeDate
		)
		VALUES (@OltpPostingGroupAuditId,@PostingGroupId,@CustomerId,'S',@DataExtractTypeId,@OdsVersion,@CoreDBVersionId,@SnapshotCreateDate,GETDATE(),GETDATE())

	SELECT TOP 1 @PostingGroupAuditId  = PostingGroupAuditId 
	FROM adm.PostingGroupAudit 
	WHERE SnapshotCreateDate = @SnapshotCreateDate 
	AND CustomerId = @CustomerId
	END
-- If ever get a zero, means previous posting group was not completed or is second full load.
SELECT ISNULL(@PostingGroupAuditId,0),ISNULL(@LatestCoreDBVersionId,0);

END

GO
