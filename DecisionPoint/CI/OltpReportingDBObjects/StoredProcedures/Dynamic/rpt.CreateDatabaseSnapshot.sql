IF OBJECT_ID('rpt.CreateDatabaseSnapshot') IS NOT NULL
    DROP PROCEDURE rpt.CreateDatabaseSnapshot
GO

CREATE PROCEDURE rpt.CreateDatabaseSnapshot
    (
      @DatabaseName VARCHAR(100) = NULL
    )
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @DBSnapshotName VARCHAR(100) ,
        @SnapshotCreateDate DATETIME2 ,
        @Timestamp VARCHAR(14) ,
        @DBLogicalName VARCHAR(100) ,
        @DBPath VARCHAR(100) ,
        @Sql NVARCHAR(MAX) ,
        @SpExecuteSql NVARCHAR(MAX) ,
        @CurrentCTVersion BIGINT ,
        @DPAppVersion VARCHAR(10) ,
        @DPAppVersionId INT ,
        @DMAppVersion VARCHAR(10) ,
        @DMAppVersionId INT ,
        @MMedStaticDataVersionId INT ,
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
    SET @SnapshotCreateDate = GETDATE();
    SET @SnapshotCreateDate = DATEADD(ms, -DATEPART(ms, @SnapshotCreateDate), @SnapshotCreateDate); -- Remove milliseconds from date
    SET @Timestamp = CONVERT(VARCHAR(8), @SnapshotCreateDate, 112) + RIGHT('0' + CAST(DATEPART(hh, @SnapshotCreateDate) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DATEPART(mi, @SnapshotCreateDate) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DATEPART(ss, @SnapshotCreateDate) AS VARCHAR(2)), 2);
    SET @DBSnapshotName = @DatabaseName + '_' + @Timestamp;

	SET @Sql = 'CREATE DATABASE' + @CRLF
		  + @TB + '[' + @DBSnapshotName + ']' + @CRLF
		  + 'ON' 

	SELECT
		@Sql += 
		  +	CASE WHEN y.FileSequence = 1
				THEN @TB
				ELSE ' ,' + @TB
				END
		  +	'(   ' + 'NAME = [' + y.LogicalFileName + ']' 
		  +	'  ,  FILENAME = ' + @SQ + y.SnapshotFileName + @SQ 
		  +	'  )' + @CRLF
	FROM
		(
		SELECT
			SnapshotFileName ,
			LogicalFileName ,
			FileSequence 
		FROM
			(
			SELECT	REVERSE(SUBSTRING(REVERSE(mf.physical_name), CHARINDEX('\', REVERSE(mf.physical_name)), 520)) + mf.name + '_' + @Timestamp + '.ss' AS SnapshotFileName ,
				mf.name AS LogicalFileName ,
				RANK() OVER (ORDER BY mf.name) AS FileSequence
			FROM	sys.master_files mf
			INNER JOIN sys.databases d ON mf.database_id = d.database_id
			WHERE     d.NAME = @DatabaseName
			AND	mf.type = 0
			) x
		) y
	;

	SET @Sql += 
		  + 'AS SNAPSHOT OF' + @CRLF
		  + @TB + '[' + @DatabaseName + ']' + @CRLF
		  + ';' + @CRLF
	;

-- Now let's create the snapshot
    BEGIN TRY
        EXEC (@Sql);

-- Assuming the snapshot was created successfully, we're going to query it for info we'll need to produce our
-- data extracts.  
        SET @SpExecuteSql = @DbSnapshotName + '.sys.sp_executesql' -- This allows me to make calls on our snapshot without changing the db context

-- Get @CurrentCTVersion
        EXEC @SpExecuteSql N'SELECT @CurrentCTVersion = CHANGE_TRACKING_CURRENT_VERSION()', N'@CurrentCTVersion BIGINT OUTPUT', @CurrentCTVersion = @CurrentCTVersion OUTPUT

-- Get @DPAppVersion, @DPAppVersionId
        EXEC @SpExecuteSql N'SELECT TOP 1  @DPAppVersion = AppVersion, @DPAppVersionId = AppVersionId FROM dbo.AppVersion WHERE AppVersion IS NOT NULL ORDER BY AppVersionId DESC', N'@DPAppVersion VARCHAR(10) OUTPUT, @DPAppVersionId INT OUTPUT', @DPAppVersion = @DPAppVersion OUTPUT, @DPAppVersionId = @DPAppVersionId OUTPUT

-- Get @MMedStaticDataVersionId
        EXEC @SpExecuteSql N'SELECT TOP 1  @MMedStaticDataVersionId = AppVersionId FROM dbo.MMedStaticDataAppVersion WHERE DataUpdateVersion IS NOT NULL ORDER BY AppVersionId DESC', N'@MMedStaticDataVersionId INT OUTPUT', @MMedStaticDataVersionId = @MMedStaticDataVersionId OUTPUT

-- Get @DMAppVersion, @DMAppVersionId, if they exist
        EXEC @SpExecuteSql N'IF OBJECT_ID(''dm.AppVersion'', ''U'') IS NOT NULL
SELECT TOP 1  @DMAppVersion = AppVersion, @DMAppVersionId = AppVersionId FROM dm.AppVersion WHERE AppVersion IS NOT NULL ORDER BY AppVersionId DESC
ELSE IF OBJECT_ID(''aw.AppVersion'', ''U'') IS NOT NULL
SELECT TOP 1  @DMAppVersion = AppVersion, @DMAppVersionId = AppVersionId FROM aw.AppVersion WHERE AppVersion IS NOT NULL ORDER BY AppVersionId DESC', N'@DMAppVersion VARCHAR(10) OUTPUT, @DMAppVersionId INT OUTPUT', @DMAppVersion = @DMAppVersion OUTPUT, @DMAppVersionId = @DMAppVersionId OUTPUT

-- Return info about newly created snapshot to client
        SELECT  @DBSnapshotName AS DBSnapshotName ,
                @CurrentCTVersion AS CurrentCTVersion ,
                @DPAppVersion AS DpAppVersion ,
                @SnapshotCreateDate AS SnapshotCreateDate ,
                @@SERVERNAME AS DBSnapshotServer ,
                @DPAppVersionId AS DpAppVersionId ,
                @MMedStaticDataVersionId AS MMedStaticDataVersionId ,
				@DMAppVersion AS DMAppVersion ,
				@DMAppVersionId AS DMAppVersionId

    END TRY

    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION

        SELECT  @ErrMsg = ERROR_MESSAGE() ,
                @ErrSeverity = ERROR_SEVERITY()

		-- Drop the snapshot (it won't rollback with the transaction); if something failed at this step, 
		-- we don't want it hanging around since we'll have to recreate the snapshot anyway.
        EXEC ('DROP DATABASE ' + @DBSnapshotName + ';');

        RAISERROR (@ErrMsg, @ErrSeverity, 1) WITH LOG

        RETURN
    END CATCH
END
GO
