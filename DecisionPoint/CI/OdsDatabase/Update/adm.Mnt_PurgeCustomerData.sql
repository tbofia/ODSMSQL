
DECLARE  @CustomerId INT = 0
        ,@SQLScript VARCHAR(MAX) = 'CREATE TABLE '
        ,@StagingSchemaName CHAR(3) = 'stg'
		,@TargetTableName VARCHAR(255)
		,@returnstatus INT;

-- Setup Cursor to go through all processes to remove customer
DECLARE @ProcessId INT
DECLARE db_cursor CURSOR FOR  
SELECT ProcessId
FROM adm.Process
WHERE PostingGroupId = 1

OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @ProcessId

WHILE @@FETCH_STATUS = 0   
BEGIN 

SET @TargetTableName = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId);
SET @SQLScript = 'DROP TABLE '+	@StagingSchemaName +'.'+@TargetTableName+'_Unpartitioned;';
EXEC adm.Mnt_SwitchPartitionOut @ProcessId ,@CustomerId ,@returnstatus = @returnstatus OUTPUT
EXEC (@SQLScript);

FETCH NEXT FROM db_cursor INTO @ProcessId

END

CLOSE db_cursor   
DEALLOCATE db_cursor

-- Cleanup Audit tables
DELETE P
FROM adm.ProcessAudit P
INNER JOIN adm.PostingGroupAudit PGA
ON P.PostingGroupAuditId  = PGA.PostingGroupAuditId
WHERE PGA.CustomerId = @CustomerId;

DELETE FROM adm.PostingGroupAudit
WHERE CustomerId = @CustomerId;
