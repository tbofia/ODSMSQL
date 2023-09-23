IF OBJECT_ID('adm.Etl_ReduceStagingDataWithHashbytes', 'P') IS NOT NULL
    DROP PROCEDURE adm.Etl_ReduceStagingDataWithHashbytes
GO

CREATE PROCEDURE adm.Etl_ReduceStagingDataWithHashbytes (
@CustomerId INT, 
@ProcessId INT,
@OdsPostingGroupAuditId INT,
@DataExtractTypeId INT,
@returnstatus INT OUTPUT)
AS
BEGIN
-- DECLARE @CustomerId INT = 68, @ProcessId INT = 153, @OdsPostingGroupAuditId INT = 1, @DataExtractTypeId INT = 2,@returnstatus INT;
DECLARE	 @SQLScript VARCHAR(MAX) = CAST('' AS VARCHAR(MAX))
		,@JoinClause VARCHAR(MAX)
		,@StgColumnList VARCHAR(MAX)
		,@TargetSchemaName CHAR(3) = (SELECT TargetSchemaName FROM adm.Process WHERE ProcessId = @ProcessId)
		,@TargetTableName VARCHAR(255) = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId)
		,@StagingSchemaName CHAR(3) = N'stg'
		,@HashbyteFunction VARCHAR(MAX)
		,@Hashbytecolumns VARCHAR(MAX)
		,@RowCount INT=0
		,@KeyColumns VARCHAR(255)
		,@KeyColumnSingle VARCHAR(255)
		,@KeyColumnCommaSeparated VARCHAR(255);
DECLARE  @KeyColumnsList TABLE (TargetColumnName VARCHAR(255));
DECLARE  @SQLScriptSP NVARCHAR(MAX) = '';

-- 1.0 Get Join Clause for the given process to Join staging and Target	
INSERT INTO @KeyColumnsList	
SELECT DISTINCT I.COLUMN_NAME AS TargetColumnName
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE I
INNER JOIN adm.Process P
	ON I.TABLE_NAME = P.TargetTableName
	AND OBJECTPROPERTY(OBJECT_ID(I.CONSTRAINT_SCHEMA + '.' + I.CONSTRAINT_NAME), 'IsPrimaryKey') = 1
	AND I.TABLE_SCHEMA = @TargetSchemaName
WHERE P.TargetTableName = @TargetTableName
	AND I.COLUMN_NAME NOT IN ('OdsCustomerId','OdsPostingGroupAuditId')
	
SET @KeyColumnSingle = (SELECT TOP 1 TargetColumnName FROM @KeyColumnsList);
	
SELECT @JoinClause =  COALESCE(@JoinClause+' AND ','')+'T.'+TargetColumnName+' = S.'+TargetColumnName
FROM @KeyColumnsList;

-- 2.0 Get Column list for Staging tables	
SELECT @stgColumnList =  COALESCE(@stgColumnList+CHAR(13)+CHAR(10)+CHAR(9)+',','')+'S.'+COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = @StagingSchemaName
AND TABLE_NAME = @TargetTableName
AND COLUMN_NAME <> 'DmlOperation'
ORDER BY ORDINAL_POSITION;

-- Build Hash value with columns, function to use depends on the process.
-- 3.0 Get Hash column list for staging table
SET @HashbyteFunction = adm.Etl_GenerateProcessHashbytes(@ProcessId);

-- 4.0 Update Snapshot Data that has been deleted.
IF ((SELECT IsSnapshot FROM adm.Process WHERE ProcessId = @ProcessId) = 1 OR @DataExtractTypeId = 2) 
BEGIN
	 -- Count Records In staging
	SET @SQLScriptSP = 'SELECT @RowCount = COUNT(1) FROM '+@StagingSchemaName+'.'+@TargetTableName;
	EXEC sp_executesql @SQLScriptSP,N'@RowCount INT out',@RowCount out;

	-- Only Delete records if there is data in staging to compare to. (Note If All Data is deleted at source, Target will not delete)
	IF (@RowCount > 0) 
	BEGIN

		SELECT @KeyColumnCommaSeparated =  COALESCE(@KeyColumnCommaSeparated+CHAR(13)+CHAR(10)+' ,','')+TargetColumnName
		FROM @KeyColumnsList;
		
		SELECT @KeyColumns =  COALESCE(@KeyColumns+CHAR(13)+CHAR(10)+' ,','')+'T.'+TargetColumnName
		FROM @KeyColumnsList;
		
		-- This is to mark records deleted from the source to IsNotCurrent.
		SET @SQLScript =@SQLScript+
						'INSERT INTO '+@StagingSchemaName+'.'+@TargetTableName+'('+CHAR(13)+CHAR(10)+'  '+@KeyColumnCommaSeparated+CHAR(13)+CHAR(10)+' ,DmlOperation)'+CHAR(13)+CHAR(10)+
						'SELECT '+@KeyColumns+CHAR(13)+CHAR(10)+' ,''D'''+CHAR(13)+CHAR(10)+
						'FROM '+@TargetSchemaName+'.'+@TargetTableName+' T'+CHAR(13)+CHAR(10)+
						'LEFT OUTER JOIN '+@StagingSchemaName+'.'+@TargetTableName+' S'+CHAR(13)+CHAR(10)+CHAR(9)+
						'ON '+@JoinClause+''+CHAR(13)+CHAR(10)+
						'WHERE T.OdsCustomerId = '+CAST(@CustomerId AS VARCHAR(3))+''+CHAR(13)+CHAR(10)+CHAR(9)+
						'AND T.OdsRowIsCurrent = 1'+CHAR(13)+CHAR(10)+CHAR(9)+
						'AND S.'+@KeyColumnSingle+' IS NULL'+';'
						
		EXEC(@SQLScript);	
	END
END

-- 5.0 Reduce Staging Data using Generated Hashbytes
SET @SQLScript = 'SELECT '+ @stgColumnList+CHAR(13)+CHAR(10)+CHAR(9)+
	',S.DmlOperation'+CHAR(13)+CHAR(10)+CHAR(9)+
	@HashbyteFunction+CHAR(13)+CHAR(10)+
'INTO '+'#'+@TargetTableName+'
FROM '+@StagingSchemaName+'.'+@TargetTableName+' S;'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+

'-- Truncate Staging Table	
TRUNCATE TABLE '+@StagingSchemaName+'.'+@TargetTableName+';'+CHAR(9)+CHAR(9)+'

-- Reinsert Data into staging table
INSERT INTO '+@StagingSchemaName+'.'+@TargetTableName+'('+CHAR(9)+@stgColumnList+CHAR(13)+CHAR(10)+CHAR(9)+',DmlOperation)'+CHAR(9)+'
SELECT '+@stgColumnList+CHAR(13)+CHAR(10)+CHAR(9)+',S.DmlOperation
FROM '+'#'+@TargetTableName+' S
LEFT OUTER JOIN '+@TargetSchemaName+'.'+@TargetTableName+' T
ON '+@JoinClause+'
	AND T.OdsCustomerId = '+CAST(@CustomerId AS VARCHAR(3))+'
	AND T.OdsRowIsCurrent = 1
WHERE T.OdsHashbytesValue <> S.OdsHashbytesValue
OR T.'+@KeyColumnSingle +' IS NULL
OR (S.DmlOperation = ''D'' AND T.DmlOperation <>''D'')
OR (S.DmlOperation <>''D'' AND T.DmlOperation = ''D'');'

BEGIN TRY
EXEC(@SQLScript);
SET @returnstatus = 0
END TRY
BEGIN CATCH
PRINT 'Data Reduction Query failed...'
SET @returnstatus = 1
END CATCH
END

GO
