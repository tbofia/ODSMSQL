SET NOCOUNT ON;
-- Delete Audit Information for removed processes
DELETE PA 
FROM adm.ProcessAudit PA
LEFT OUTER JOIN adm.Process P
ON PA.ProcessId = P.ProcessId
WHERE P.ProcessId IS NULL

-- Remove objects associated with removed processes
DECLARE  @TargetTableName VARCHAR(100)
		,@Sql VARCHAR(MAX);

BEGIN TRANSACTION 
BEGIN TRY
	DECLARE cr_tablename CURSOR FOR 
	SELECT I.TABLE_NAME
	FROM INFORMATION_SCHEMA.TABLES I
	LEFT OUTER JOIN adm.Process P
	ON I.TABLE_NAME = P.TargetTableName
	WHERE TABLE_SCHEMA = 'src'
	AND P.TargetTableName IS NULL

	OPEN cr_tablename

	FETCH NEXT FROM cr_tablename 
	INTO @TargetTableName

	WHILE @@FETCH_STATUS = 0
	BEGIN
	
	SET @Sql ='
	-- Drop View
	IF OBJECT_ID(''dbo.'+@TargetTableName+''', ''V'') IS NOT NULL
    DROP VIEW dbo.'+@TargetTableName+';

	-- Drop Function
	IF OBJECT_ID(''dbo.if_'+@TargetTableName+''', ''IF'') IS NOT NULL
    DROP FUNCTION dbo.if_'+@TargetTableName+';
	
	-- Drop Staging and src tables
	IF OBJECT_ID(''src.'+@TargetTableName+''', ''U'') IS NOT NULL
	DROP TABLE src.'+@TargetTableName+';
	
	IF OBJECT_ID(''stg.'+@TargetTableName+''', ''U'') IS NOT NULL
	DROP TABLE stg.'+@TargetTableName+';' 

	EXEC(@Sql)

	FETCH NEXT FROM cr_tablename
	INTO @TargetTableName
	
	END

	CLOSE cr_tablename
	DEALLOCATE cr_tablename

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	PRINT 'Errors. Could Not Drop Objects.. '
	ROLLBACK TRANSACTION
END CATCH
GO
