-- Now, let's enable change tracking on Child and Core Databases
SET XACT_ABORT ON;

DECLARE  @Sql NVARCHAR(MAX)
		,@BaseFileName VARCHAR(100)
		,@ChildDBName VARCHAR(MAX) = DB_NAME()
		,@CoreDBName VARCHAR(MAX)
		,@TableDatabaseName VARCHAR(MAX);

-- Obtain Core Database name
SET  @Sql = 'IF EXISTS  (SELECT  1
            FROM    '+@ChildDBName+'.sys.columns
            WHERE   object_id = OBJECT_ID(N''dbo.SiteInfo'')
                        AND NAME = ''ShareFSDb'')
SET @CoreDBName = (SELECT ShareFSDb FROM dbo.SiteInfo)'

EXEC sp_executesql @Sql,N'@CoreDBName VARCHAR(MAX) OUTPUT',@CoreDBName = @CoreDBName OUTPUT;

-- we're going to set the retention period Child Database to 10 days.

IF NOT EXISTS ( SELECT  1
					FROM    sys.change_tracking_databases ct
					WHERE   DB_NAME(ct.database_id) = (SELECT @ChildDBName)
							AND ct.retention_period = 10
							AND ct.retention_period_units_desc = 'DAYS' )
	BEGIN
		SET @Sql = 'ALTER DATABASE [' + (SELECT @ChildDBName) + '] SET CHANGE_TRACKING = ON (CHANGE_RETENTION = 10 DAYS, AUTO_CLEANUP = ON);'
		EXEC (@Sql);
	END

-- we're going to set the retention period Core Database to 10 days if only a core database exists (i.e not standalone customer).
IF NOT EXISTS ( SELECT  1
					FROM    sys.change_tracking_databases ct
					WHERE   DB_NAME(ct.database_id) = (SELECT @CoreDBName)
							AND ct.retention_period = 10
							AND ct.retention_period_units_desc = 'DAYS' ) AND EXISTS ( SELECT  1
            FROM    sys.databases
            WHERE   name = @CoreDBName )
	BEGIN
		SET @Sql = 'ALTER DATABASE [' + (SELECT @CoreDBName) + '] SET CHANGE_TRACKING = ON (CHANGE_RETENTION = 10 DAYS, AUTO_CLEANUP = ON);'
		EXEC (@Sql);
	END

-- Enable chnage tracking for tables in rpt.Process which are non snapshot tables
BEGIN TRANSACTION 
BEGIN TRY
	DECLARE cr_tablename CURSOR FOR 
	SELECT BaseFileName 
	FROM rpt.Process
	WHERE IsSnapshot = 0

	OPEN cr_tablename

	FETCH NEXT FROM cr_tablename
	INTO @BaseFileName

	WHILE @@FETCH_STATUS = 0
	BEGIN
	-- Check if its is a table or a view to see where to enable chnage tracking
	SET @TableDatabaseName = (SELECT CASE WHEN EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='VIEW' AND TABLE_NAME = @BaseFileName) THEN @CoreDBName ELSE @ChildDBName END)

	SET @Sql =  'USE '+@TableDatabaseName+'
				IF NOT EXISTS ( SELECT  object_id 
								FROM    sys.change_tracking_tables 
								WHERE object_id = OBJECT_ID(''dbo.'+@BaseFileName+''') ) 
				IF OBJECT_ID(''dbo.'+@BaseFileName+''', ''U'') IS NOT NULL 
				ALTER TABLE '+@TableDatabaseName+'.dbo.'+@BaseFileName+'
				ENABLE CHANGE_TRACKING
				WITH(TRACK_COLUMNS_UPDATED = OFF);' 

	EXEC(@Sql)

	FETCH NEXT FROM cr_tablename
	INTO @BaseFileName
	
	END

	CLOSE cr_tablename
	DEALLOCATE cr_tablename

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	PRINT 'Errors. Change Tracking Could not be enabled... '
	ROLLBACK TRANSACTION
END CATCH
