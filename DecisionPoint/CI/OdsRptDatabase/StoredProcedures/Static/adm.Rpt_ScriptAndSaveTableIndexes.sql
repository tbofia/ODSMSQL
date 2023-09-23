IF OBJECT_ID('adm.Rpt_ScriptAndSaveTableIndexes', 'P') IS NOT NULL
    DROP PROCEDURE adm.Rpt_ScriptAndSaveTableIndexes
GO

CREATE PROCEDURE adm.Rpt_ScriptAndSaveTableIndexes (
@ProcessId INT)
AS
BEGIN
-- DECLARE @ReportId INT=1,@ReportType INT=1

DECLARE  @SQLScript VARCHAR(MAX)
		,@DropIdxScript VARCHAR(MAX)
		,@TargetSchemaName CHAR(3) = (SELECT TargetSchemaName FROM adm.Process WHERE ProcessId = @ProcessId)	
		,@TargetTableName VARCHAR(255) = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId);
		
-- Get Index Key Columns
;WITH Ods_IndexColumns AS(
SELECT IC2.object_id,
      IC2.index_id,
      STUFF(( SELECT ',' + C.name + CASE WHEN MAX(CONVERT(INT, IC1.is_descending_key)) = 1 THEN ' DESC' ELSE ' ASC' END
              FROM   sys.index_columns IC1
              INNER  JOIN sys.columns C
                  ON  C.object_id = IC1.object_id
                  AND C.column_id = IC1.column_id
                  AND IC1.is_included_column = 0
              WHERE  IC1.object_id = IC2.object_id  AND IC1.index_id = IC2.index_id
              GROUP BY IC1.object_id,C.name, index_id
              ORDER BY  MAX(IC1.key_ordinal) 
              FOR XML PATH('')),1,1,'') KeyColumns,
      STUFF(( SELECT ',' + C.name
			  FROM   sys.index_columns IC1
			  INNER  JOIN sys.columns C
				  ON  C.object_id = IC1.object_id
				  AND C.column_id = IC1.column_id
				  AND IC1.is_included_column = 1
			  WHERE  IC1.object_id = IC2.object_id  AND IC1.index_id = IC2.index_id
			  GROUP BY IC1.object_id,C.name,index_id 
			  FOR XML PATH('')),1,1,'') IncludedColumns
FROM   sys.index_columns IC2 
GROUP BY IC2.object_id,IC2.index_id)
-- Build Index script or Primary key constraint.
SELECT @SQLScript =  COALESCE(@SQLScript+CHAR(13)+CHAR(10)+'','')+
	 CASE WHEN I.is_primary_key = 1 
		  THEN 'ALTER TABLE '+@TargetSchemaName + '.' + @TargetTableName+' ADD CONSTRAINT '+I.name
		  ELSE 'CREATE ' END+
	 CASE WHEN I.is_primary_key <> 1 AND I.is_unique = 1 THEN ' UNIQUE '   ELSE ''  END +
	 CASE WHEN I.is_primary_key = 1 THEN ' PRIMARY KEY ' ELSE '' END+
	 I.type_desc COLLATE DATABASE_DEFAULT + CASE WHEN I.is_primary_key <> 1 THEN ' INDEX ' ELSE '' END +
	 CASE WHEN I.is_primary_key <> 1 THEN  I.name + ' ON ' ELSE '' END+
	 CASE WHEN I.is_primary_key <> 1 THEN  @TargetSchemaName + '.' + @TargetTableName  ELSE '' END+ 
	   ' ('+IC.KeyColumns+')  ' +
	   ISNULL(' INCLUDE(' + IC.IncludedColumns + ') ', '')+
	   'WITH (DATA_COMPRESSION = PAGE);'+CHAR(13)+CHAR(10)
	,@DropIdxScript = COALESCE(@DropIdxScript+CHAR(13)+CHAR(10)+'','')+ 
		'DROP INDEX '+ I.name+' ON '+ @TargetSchemaName + '.' + @TargetTableName+';'+CHAR(13)+CHAR(10)

FROM   sys.indexes I
INNER JOIN sys.tables T
ON  T.object_id = I.object_id
INNER JOIN Ods_IndexColumns IC
	ON I.object_id = IC.object_id
	AND I.index_id = IC.index_id

WHERE T.name = @TargetTableName
	AND SCHEMA_NAME(T.schema_id) = @TargetSchemaName
	AND I.type <> 0
ORDER BY I.Index_id

-- Execute Script to build indexes aligned with target table
BEGIN TRY
UPDATE adm.Process
SET IndexScript = CASE WHEN @SQLScript <> '' AND @SQLScript IS NOT NULL THEN @SQLScript ELSE IndexScript END
WHERE ProcessId = @ProcessId;

EXEC(@DropIdxScript);

END TRY
BEGIN CATCH
PRINT 'Indexes Could Not be Scripted Or Dropped...Make sure table exists and indexes have been created on it.'
END CATCH

END
GO
