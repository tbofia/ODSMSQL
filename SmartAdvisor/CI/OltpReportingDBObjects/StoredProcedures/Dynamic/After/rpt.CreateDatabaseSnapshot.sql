IF OBJECT_ID('rpt.CreateDatabaseSnapshot') IS NOT NULL
    DROP PROCEDURE rpt.CreateDatabaseSnapshot
GO

CREATE PROCEDURE rpt.CreateDatabaseSnapshot(
@DatabaseName VARCHAR(100) = NULL,
@DBSnapshotName VARCHAR(100) = NULL OUTPUT,
@CurrentCTVersion BIGINT = NULL OUTPUT,
@SnapshotCreateDate DATETIME2 = NULL OUTPUT,
@DBSnapshotServer VARCHAR(100)  = NULL OUTPUT)
AS
BEGIN
	--DECLARE @DatabaseName VARCHAR(100) = NULL
    SET NOCOUNT ON

    DECLARE  @Timestamp VARCHAR(14) ,
        @Sql NVARCHAR(MAX) ,
        @SpExecuteSql NVARCHAR(MAX) ,
        @ErrMsg NVARCHAR(4000) ,
        @ErrSeverity INT ,
-- This is for you, Dustin...
        @CRLF NCHAR(2)	= CHAR(13) + CHAR(10) ,	-- Carriage Return + Line Feed
        @TB NCHAR(1)	= CHAR(9) ,		-- Tab character
        @SQ NCHAR(1)	= CHAR(39)		-- Single quote character

    SET @DatabaseName = ISNULL(@DatabaseName, DB_NAME());

    IF NOT EXISTS ( SELECT  1
                    FROM    sys.databases
                    WHERE   name = @DatabaseName )
        RAISERROR ('@DatabaseName does not exist on this server.  Aborting.', 16, 1) WITH LOG

-- Now, let's create the SQL to create our snapshot
    SET @SnapshotCreateDate = ISNULL(@SnapshotCreateDate,GETDATE());
    SET @SnapshotCreateDate = DATEADD(ms, -DATEPART(ms, @SnapshotCreateDate), @SnapshotCreateDate); -- Remove milliseconds from date
    SET @Timestamp = CONVERT(VARCHAR(8), @SnapshotCreateDate, 112) + RIGHT('0' + CAST(DATEPART(hh, @SnapshotCreateDate) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DATEPART(mi, @SnapshotCreateDate) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DATEPART(ss, @SnapshotCreateDate) AS VARCHAR(2)), 2);
    SET @DBSnapshotName = @DatabaseName + '_' + @Timestamp;

	SET @Sql = 'CREATE DATABASE [' + @DBSnapshotName + ']' + @CRLF + 'ON' 
		  
	;WITH cte_SnapshotInfo AS(
	SELECT	REVERSE(SUBSTRING(REVERSE(mf.physical_name), CHARINDEX('\', REVERSE(mf.physical_name)), 520)) + mf.name + '_' + @Timestamp + '.ss' AS SnapshotFileName ,
		mf.name AS LogicalFileName ,
		RANK() OVER (ORDER BY mf.name) AS FileSequence
	FROM	sys.master_files mf
	INNER JOIN sys.databases d ON mf.database_id = d.database_id
	WHERE     d.NAME = @DatabaseName
	AND	mf.type = 0)

	SELECT  @Sql += +CASE WHEN y.FileSequence = 1
				THEN @TB
				ELSE ' ,' + @TB
				END
		  +	'(' + 'NAME = [' + y.LogicalFileName + ']' 
		  +	'  ,  FILENAME = ' + @SQ + y.SnapshotFileName + @SQ 
		  +	')' + @CRLF
	FROM cte_SnapshotInfo y

	SET @Sql = @Sql + 'AS SNAPSHOT OF [' + @DatabaseName + '];' + @CRLF

-- Now let's create the snapshot
    BEGIN TRY
        EXEC (@Sql);

-- Assuming the snapshot was created successfully, we're going to query it for info we'll need to produce our
-- data extracts.  
        SET @SpExecuteSql = @DbSnapshotName + '.sys.sp_executesql' -- This allows me to make calls on our snapshot without changing the db context

-- Get @CurrentCTVersion
        EXEC @SpExecuteSql N'SELECT @CurrentCTVersion = CHANGE_TRACKING_CURRENT_VERSION()', N'@CurrentCTVersion BIGINT OUTPUT', @CurrentCTVersion = @CurrentCTVersion OUTPUT
-- Return info about newly created snapshot to client
        SET @DBSnapshotServer= @@SERVERNAME

    END TRY

    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION

        SELECT  @ErrMsg = ERROR_MESSAGE() ,
                @ErrSeverity = ERROR_SEVERITY()

		-- Drop the snapshot (it won't rollback with the transaction); if something failed at this step, 
		-- we don't want it hanging around since we'll have to recreate the snapshot anyway.
        EXEC rpt.DropDatabaseSnapshot @DBSnapshotName;

        RAISERROR (@ErrMsg, @ErrSeverity, 1) WITH LOG

    END CATCH
	RETURN 
END
GO
