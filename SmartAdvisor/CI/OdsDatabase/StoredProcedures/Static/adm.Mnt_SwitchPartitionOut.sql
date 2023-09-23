IF OBJECT_ID('adm.Mnt_SwitchPartitionOut', 'P') IS NOT NULL
    DROP PROCEDURE adm.Mnt_SwitchPartitionOut
GO
CREATE PROCEDURE adm.Mnt_SwitchPartitionOut(
@ProcessId INT,
@CustomerId INT,
@returnstatus INT = 1 OUTPUT)
AS
BEGIN
-- DECLARE @ProcessId INT = 6, @CustomerId INT = 42, @returnstatus INT = 1

DECLARE  @SQLScript VARCHAR(MAX)
		,@TargetSchemaName CHAR(3) = N'src'
		,@StagingSchemaName CHAR(3) = N'stg'
		,@TargetTableName VARCHAR(255) = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId)	;

-- Create schema, note: Schema will be created only if it does not exist.
EXEC adm.Etl_CreateUnpartitionedTableSchema @CustomerId, @ProcessId,1,@returnstatus = @returnstatus OUTPUT

-- Creates Indexes on empty unpartitionned table, note: Indexes will be created only if they do no alreday exist
EXEC adm.Etl_CreateUnpartitionedTableIndexes @CustomerId,@ProcessId,@returnstatus = @returnstatus OUTPUT

-- Switch customer data into empty table,Note: Switch only happens if the table is empty
EXEC adm.Etl_SwitchUnpartitionedTable @CustomerId, @ProcessId,'',1,@returnstatus = @returnstatus OUTPUT

END

GO 
  
