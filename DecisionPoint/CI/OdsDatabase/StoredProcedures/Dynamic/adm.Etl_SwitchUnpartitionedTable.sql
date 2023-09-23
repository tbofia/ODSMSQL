IF OBJECT_ID('adm.Etl_SwitchUnpartitionedTable', 'P') IS NOT NULL
    DROP PROCEDURE adm.Etl_SwitchUnpartitionedTable
GO

CREATE PROCEDURE adm.Etl_SwitchUnpartitionedTable (
@CustomerId INT,
@ProcessId INT,
@TargetNameExtension VARCHAR(100) = '',
@SwitchOut INT = 0,
@returnstatus INT OUTPUT)
AS
BEGIN

-- DECLARE @ProcessId INT = 19,@CustomerId INT = 69,@TargetNameExtension VARCHAR(100) = '_',@returnstatus INT,@SwitchOut INT = 0;
DECLARE  @SQLScript VARCHAR(MAX) = ''
		,@StagingSchemaName CHAR(3) = 'stg'
		,@TargetSchemaName CHAR(3) = (SELECT TargetSchemaName FROM adm.Process WHERE ProcessId = @ProcessId)	
		,@TargetTableName VARCHAR(255) = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId);
-- Check switch direction and switch accordingly
IF @SwitchOut = 0
	BEGIN
	-- Make sure check constraint exists before you switch in.
	SET @SQLScript = @SQLScript +
	'IF NOT EXISTS (SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS'+CHAR(13)+CHAR(10)+
	'WHERE CONSTRAINT_NAME = ''CK_'+@TargetTableName+'_CustomerPartitionCheck'''+CHAR(13)+CHAR(10)+
	'AND CONSTRAINT_SCHEMA = '''+@StagingSchemaName+''')'+CHAR(13)+CHAR(10)+
	'ALTER TABLE '+ @StagingSchemaName +'.'+@TargetTableName+'_Unpartitioned'+CHAR(13)+CHAR(10)+
	'ADD CONSTRAINT CK_'+@TargetTableName+'_CustomerPartitionCheck CHECK (OdsCustomerId = '+CAST(@CustomerId AS VARCHAR(5))+');'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
					  
	SET @SQLScript = @SQLScript+
	'ALTER TABLE '+@StagingSchemaName+'.'+@TargetTableName+'_Unpartitioned'+ 
	' SWITCH TO '+@TargetSchemaName+'.'+@TargetTableName+@TargetNameExtension+' PARTITION '+CAST(@CustomerId AS VARCHAR(5))+';'+CHAR(13)+CHAR(10)+
	'DROP TABLE '+@StagingSchemaName+'.'+@TargetTableName+'_Unpartitioned'+'';
	END
ELSE 
	SET @SQLScript = 'ALTER TABLE '+@TargetSchemaName+'.'+@TargetTableName+@TargetNameExtension+ 
	' SWITCH PARTITION '+CAST(@CustomerId AS VARCHAR(5))+' TO '+@StagingSchemaName+'.'+@TargetTableName+'_Unpartitioned'+';'+CHAR(13)+CHAR(10)
	
-- If Indexes were successfully built, switch Partitions

BEGIN TRY
EXEC(@SQLScript)
SET @returnstatus = 0
END TRY
BEGIN CATCH
PRINT 'Could Not Switch Partitions...'
SET @returnstatus = 1
END CATCH

END

GO
