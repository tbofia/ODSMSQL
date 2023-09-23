-- Now, let's Disable change tracking on Child and Core Databases
SET XACT_ABORT ON;

DECLARE  @Sql NVARCHAR(MAX)
		,@BaseFileName VARCHAR(100)
		,@ChildDBName VARCHAR(MAX) = DB_NAME()
		,@CoreDBName VARCHAR(MAX)
		,@TableDatabaseName VARCHAR(MAX)
		,@SchemaName VARCHAR(MAX)
		,@MinOdsVersion VARCHAR(10) ;
SET @MinOdsVersion = ( SELECT TOP 1 LEFT(AppVersion, CHARINDEX('.', AppVersion, CHARINDEX('.', AppVersion)+1)-1) FROM rpt.AppVersion 
						ORDER BY [AppVersionId] DESC )

-- Obtain Core Database name
SET  @Sql = 'IF EXISTS  (SELECT  1
            FROM    '+@ChildDBName+'.sys.columns
            WHERE   object_id = OBJECT_ID(N''dbo.SiteInfo'')
                        AND NAME = ''ShareFSDb'')
SET @CoreDBName = (SELECT ShareFSDb FROM dbo.SiteInfo)'

EXEC sp_executesql @Sql,N'@CoreDBName VARCHAR(MAX) OUTPUT',@CoreDBName = @CoreDBName OUTPUT;

BEGIN TRANSACTION 
BEGIN TRY
	DECLARE cr_tablename CURSOR FOR 
	SELECT BaseFileName
	FROM rpt.Process
	WHERE IsSnapshot = 0
	AND MinODSVersion = @MinOdsVersion


	OPEN cr_tablename

	FETCH NEXT FROM cr_tablename
	INTO @BaseFileName

	WHILE @@FETCH_STATUS = 0
	BEGIN
	-- Check if its is a table or a view to see where to disable change tracking
	SET @TableDatabaseName = (SELECT CASE WHEN EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='VIEW' AND TABLE_NAME = @BaseFileName) THEN @CoreDBName ELSE @ChildDBName END)
	SET @SchemaName = 'dbo'

	SET @Sql = 
	'USE '+@TableDatabaseName+'
	 IF EXISTS ( SELECT  object_id 
					FROM    sys.change_tracking_tables 
					WHERE object_id = OBJECT_ID(''dbo.'+@BaseFileName+'''))
	 IF OBJECT_ID('''+@SchemaName+'.'+@BaseFileName+''', ''U'') IS NOT NULL  
	 ALTER TABLE '+@TableDatabaseName+'.dbo.'+@BaseFileName+'
	 DISABLE CHANGE_TRACKING;' 

	EXEC(@Sql)

	FETCH NEXT FROM cr_tablename
	INTO @BaseFileName
	
	END

	CLOSE cr_tablename
	DEALLOCATE cr_tablename

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	PRINT 'Errors. Change Tracking Could not be disabled... '
	ROLLBACK TRANSACTION
END CATCH




