SET NOCOUNT ON;
DECLARE	 @ProcessId INT = '$(processid_)'

DECLARE  @SQLScript NVARCHAR(MAX) = ''
		,@CommaColumnList VARCHAR(MAX)
		,@UnderscoreColumnList VARCHAR(MAX)
		,@ColumnListLength VARCHAR(MAX)
		,@TargetSchemaName CHAR(3) = N'src'
		,@TargetTableName VARCHAR(255) = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId);
DECLARE  @KeyColumnsList TABLE (TargetColumnName VARCHAR(255),TargetColumnPosition INT);

-- Get list of key columns into a table
INSERT INTO @KeyColumnsList	
SELECT DISTINCT I.COLUMN_NAME AS TargetColumnName, ORDINAL_POSITION AS TargetColumnPosition
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE I
INNER JOIN adm.Process P
	ON I.TABLE_NAME = P.TargetTableName
	AND OBJECTPROPERTY(OBJECT_ID(I.CONSTRAINT_SCHEMA + '.' + I.CONSTRAINT_NAME), 'IsPrimaryKey') = 1
	AND I.TABLE_SCHEMA = @TargetSchemaName
WHERE P.TargetTableName = @TargetTableName
	AND I.COLUMN_NAME NOT IN ('OdsCustomerId','OdsPostingGroupAuditId')
ORDER BY ORDINAL_POSITION;

-- Comma separate key columns	
SELECT @CommaColumnList =  COALESCE(@CommaColumnList+',','')+TargetColumnName 
FROM @KeyColumnsList
ORDER BY TargetColumnPosition;

-- underscore seperate key columns
SELECT @UnderscoreColumnList =  COALESCE(@UnderscoreColumnList+'_','')+TargetColumnName 
FROM @KeyColumnsList
ORDER BY TargetColumnPosition;

-- if index name will be longer then 128 then make it shorted by using only one column along with table name and audit columns
SET @UnderscoreColumnList = (SELECT CASE WHEN LEN('IX_'+@UnderscoreColumnList+'_OdsCustomerId_OdsPostingGroupAuditId') > 128 THEN (SELECT TOP 1 @TargetTableName+'_'+TargetColumnName FROM @KeyColumnsList ORDER BY TargetColumnPosition ) ELSE @UnderscoreColumnList END)

-- Build Index Scripts
SET @SQLScript =
'IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('''+@TargetSchemaName+'.'+@TargetTableName+''')
	AND NAME = ''IX_'+@UnderscoreColumnList+'_OdsCustomerId_OdsPostingGroupAuditId'')
	
CREATE NONCLUSTERED INDEX IX_'+@UnderscoreColumnList+'_OdsCustomerId_OdsPostingGroupAuditId 
ON '+@TargetSchemaName+'.'+@TargetTableName+' ('+@CommaColumnList+', OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'''+@TargetSchemaName+'.'+@TargetTableName+''')
	AND NAME = N''IX_OdsPostingGroupAuditId_DmlOperation'')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON '+@TargetSchemaName+'.'+@TargetTableName+'(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE ('+@CommaColumnList+');
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'''+@TargetSchemaName+'.'+@TargetTableName+''')
	AND NAME = N''IX_OdsCustomerId_OdsRowIsCurrent'')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON '+@TargetSchemaName+'.'+@TargetTableName+'(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,'+@CommaColumnList+');
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'''+@TargetSchemaName+'.'+@TargetTableName+''')
	AND NAME = N''IX_OdsPostingGroupAuditId'')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId
ON '+@TargetSchemaName+'.'+@TargetTableName+'(OdsPostingGroupAuditId)
INCLUDE (OdsCustomerId,OdsRowIsCurrent,OdsHashbytesValue,'+@CommaColumnList+');
GO

'

-- Run Index Creation scripts
BEGIN TRY
PRINT (@SQLScript)
END TRY
BEGIN CATCH
PRINT 'Indexes Could Not be built...Make sure table exists and no indexes have been created on it.'
END CATCH