IF OBJECT_ID('adm.Etl_InsertIntoTargetFromStaging', 'P') IS NOT NULL
    DROP PROCEDURE adm.Etl_InsertIntoTargetFromStaging
GO

CREATE PROCEDURE adm.Etl_InsertIntoTargetFromStaging (
@CustomerId INT, 
@ProcessId INT,
@OdsPostingGroupAuditId INT, 
@SnapshotDate VARCHAR(50),
@DataExtractTypeId INT,
@RowsAffected INT OUTPUT,
@returnstatus INT OUTPUT)
AS
BEGIN
-- DECLARE @CustomerId INT = 9, @ProcessId INT = 26, @OdsPostingGroupAuditId INT = 0, @SnapshotDate VARCHAR(50) = '2016-02-26 16:24:37.190',@DataExtractTypeId INT = 1;
DECLARE	 @InsertSQL VARCHAR(MAX) = 'INSERT INTO '
		,@StgColumnList VARCHAR(MAX)
		,@SrcColumnList VARCHAR(MAX)
		,@TargetSchemaName CHAR(3) = (SELECT TargetSchemaName FROM adm.Process WHERE ProcessId = @ProcessId)
		,@TargetTableName VARCHAR(255) = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId)
		,@StagingSchemaName CHAR(3) = N'stg'
		,@HashbyteFunction VARCHAR(MAX)
		,@Hashbytecolumns VARCHAR(MAX);

-- 1.0 Get column list for staging table
SELECT @stgColumnList =  COALESCE(@stgColumnList+CHAR(13)+CHAR(10)+CHAR(9)+',','')+'['+ COLUMN_NAME +']'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = @StagingSchemaName
AND TABLE_NAME = @TargetTableName
AND COLUMN_NAME <> 'DmlOperation'
ORDER BY ORDINAL_POSITION;

-- 2.0 Get Colimn list for target table
SELECT @srcColumnList =  COALESCE(@srcColumnList+CHAR(13)+CHAR(10)+CHAR(9)+',','')+'['+ COLUMN_NAME +']'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = @TargetSchemaName
AND TABLE_NAME = @TargetTableName
ORDER BY ORDINAL_POSITION;
	
-- 3.0 Generate Hashbyte column list and Decide function to use
IF ((SELECT HashFunctionType FROM adm.Process WHERE ProcessId = @ProcessId) = 2)
BEGIN
	-- Get Hash column list for staging table
	SELECT @Hashbytecolumns =  COALESCE(@Hashbytecolumns+CHAR(13)+CHAR(10)+CHAR(9)+'+','')+'CAST(ISNULL('+'['+ COLUMN_NAME +']'+', '''') AS VARBINARY(MAX))' 
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_SCHEMA = @StagingSchemaName
	AND TABLE_NAME = @TargetTableName
	AND COLUMN_NAME <> 'DmlOperation'
	ORDER BY ORDINAL_POSITION;	
	
	SET @HashbyteFunction = ',CAST(master.sys.fn_repl_hash_binary('+@Hashbytecolumns+') AS VARBINARY(8000)) OdsHashbytesValue';
END
ELSE 
	SET @HashbyteFunction = ',HASHBYTES(''SHA1'', (SELECT '+@stgColumnList+' FOR XML RAW)) OdsHashbytesValue';

-- 4.0 Insert staging data to target
SET @InsertSQL = @InsertSQL + 
CASE WHEN @DataExtractTypeId = 0 THEN @StagingSchemaName ELSE @TargetSchemaName END+'.'+@TargetTableName+
CASE WHEN @DataExtractTypeId = 0 THEN '_Unpartitioned' ELSE '' END+
' ('+@srcColumnList+') 
 SELECT	 ' +CAST(@OdsPostingGroupAuditId AS VARCHAR(10))+CHAR(13)+CHAR(10)+CHAR(9)+
		','+CAST(@CustomerId AS VARCHAR(3))+CHAR(13)+CHAR(10)+CHAR(9)+
		','''+CONVERT(VARCHAR(50),GETDATE(),121)+''''+CHAR(13)+CHAR(10)+CHAR(9)+
		','''+@SnapshotDate+''''+CHAR(13)+CHAR(10)+CHAR(9)+
		','+CASE WHEN @DataExtractTypeId IN (1,2) THEN '0' ELSE '1' END+CHAR(13)+CHAR(10)+CHAR(9)+ -- Set incr and snaps to 'isnotcurrent' until gets flipped on update.
		@HashbyteFunction+CHAR(13)+CHAR(10)+CHAR(9)+
		',DmlOperation'+CHAR(13)+CHAR(10)+CHAR(9)+
		','+@stgColumnList+CHAR(13)+CHAR(10)+CHAR(9)+
'FROM '+@StagingSchemaName+'.'+@TargetTableName+';';

BEGIN TRANSACTION InsertTrans
BEGIN TRY 
	EXEC(@InsertSQL); 
	SELECT @RowsAffected = @@ROWCOUNT,@returnstatus = 0;
COMMIT TRANSACTION InsertTrans
END TRY
BEGIN CATCH
	SELECT @RowsAffected = -1,@returnstatus = 1;
	PRINT 'Failed to load data into target table...!'
	ROLLBACK TRANSACTION InsertTrans
END CATCH

END


GO
