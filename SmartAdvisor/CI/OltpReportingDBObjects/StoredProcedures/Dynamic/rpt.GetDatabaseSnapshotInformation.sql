IF OBJECT_ID('rpt.GetDatabaseSnapshotInformation') IS NOT NULL
    DROP PROCEDURE rpt.GetDatabaseSnapshotInformation
GO

CREATE PROCEDURE rpt.GetDatabaseSnapshotInformation(
@DatabaseName VARCHAR(100) = NULL,
@DataExtractTypeId INT = 0)
AS
BEGIN
	--DECLARE @DatabaseName VARCHAR(100) = 'ODS_dB_1_Child',@DataExtractTypeId INT = 0
    SET NOCOUNT ON

    DECLARE @DBSnapshotServer VARCHAR(100),
		@HimTablesDatabase VARCHAR(100),
		@ChildDBSnapshotName VARCHAR(100) ,
		@ChildDBCTVersion BIGINT ,
		@ChildDBSiteInfoHistory INT,
		@CoreDBSnapshotName VARCHAR(100) ,
		@CoreDBCTVersion BIGINT ,
		@CoreDBSiteInfoHistory INT,
		@CoreDatabaseName VARCHAR(100),
        @SnapshotCreateDate DATETIME2 = GETDATE(),
		@SADBVersion VARCHAR(20) ,
        @SAFSVersion VARCHAR(20),
		@SiteCode VARCHAR(3),
        @Sql NVARCHAR(MAX) ,
        @SpExecuteSql NVARCHAR(MAX);

	
	IF NOT EXISTS ( SELECT  1
                    FROM    sys.databases
                    WHERE   name = @DatabaseName )
        RAISERROR ('@DatabaseName does not exist on this server.  Aborting.', 16, 1) WITH LOG
	ELSE 
    BEGIN TRY

-- Get Child Database Snapshot Info
		EXEC rpt.CreateDatabaseSnapshot 
			 @DatabaseName = @DatabaseName,
			 @DBSnapshotName  = @ChildDBSnapshotName OUTPUT,
			 @CurrentCTVersion  = @ChildDBCTVersion OUTPUT,
			 @SnapshotCreateDate  = @SnapshotCreateDate OUTPUT,
			 @DBSnapshotServer  = @DBSnapshotServer OUTPUT
	
-- Assuming the snapshot was created successfully, we're going to query it for info we'll need to produce our
-- data extracts.  
        SET @SpExecuteSql = @ChildDBSnapshotName + '.sys.sp_executesql' -- This allows me to make calls on our snapshot without changing the db context

-- Get @DBVersion, @FSVersion
        EXEC @SpExecuteSql N'SELECT TOP 1	@SiteInfoHistory = SiteInfoHistory.SiteInfoHistorySeq,
											@DBVersion = SiteInfo.DBVersion, 
											@FSVersion = SiteInfo.FSVersion, 
											@CoreDatabaseName = SiteInfo.ShareFSDb, 
											@SiteCode = SiteInfo.SiteCode
							 FROM dbo.SiteInfoHistory 
							 INNER JOIN dbo.SiteInfo 
								ON SiteInfoHistory.SiteCode = SiteInfo.SiteCode
							 ORDER BY SiteInfoHistory.SiteInfoHistorySeq DESC', 
						   N'@SiteInfoHistory INT OUTPUT,@DBVersion VARCHAR(20) OUTPUT, @FSVersion VARCHAR(20) OUTPUT, @CoreDatabaseName VARCHAR(100) OUTPUT,@SiteCode VARCHAR(3) OUTPUT', 
							 @SiteInfoHistory = @ChildDBSiteInfoHistory OUTPUT, @DBVersion = @SADBVersion OUTPUT, @FSVersion = @SAFSVersion OUTPUT,@CoreDatabaseName = @CoreDatabaseName OUTPUT,@SiteCode = @SiteCode OUTPUT;



-- If Core Database exists then get information
		IF EXISTS ( SELECT  1
                    FROM    sys.databases
                    WHERE   name = @CoreDatabaseName )
		BEGIN 

	-- Create Core Database Snapshot
			EXEC rpt.CreateDatabaseSnapshot 
				 @DatabaseName = @CoreDatabaseName,
				 @DBSnapshotName = @CoreDBSnapshotName OUTPUT,
				 @CurrentCTVersion = @CoreDBCTVersion OUTPUT; 

			SET @SpExecuteSql = @CoreDBSnapshotName + '.sys.sp_executesql' -- This allows me to make calls on our snapshot without changing the db context

			EXEC @SpExecuteSql N'SELECT TOP 1	@SiteInfoHistory = SiteInfoHistory.SiteInfoHistorySeq
								 FROM dbo.SiteInfoHistory 
								 INNER JOIN dbo.SiteInfo 
									ON SiteInfoHistory.SiteCode = SiteInfo.SiteCode
								 ORDER BY SiteInfoHistory.SiteInfoHistorySeq DESC', 
							   N'@SiteInfoHistory INT OUTPUT', 
								 @SiteInfoHistory = @CoreDBSiteInfoHistory OUTPUT;
		END
		ELSE 
		BEGIN
			SET @CoreDBSnapshotName = @ChildDBSnapshotName; 
			SET	@CoreDBCTVersion = @ChildDBCTVersion;
			SET	@CoreDBSiteInfoHistory = @ChildDBSiteInfoHistory;
		END
	
	SET @HimTablesDatabase = (SELECT CASE WHEN EXISTS (SELECT  1 FROM    sys.databases  WHERE   name = @CoreDatabaseName) THEN @CoreDatabaseName ELSE @DatabaseName  END)

-- Return info about newly created snapshot to client
        SELECT  @ChildDBSnapshotName AS ChildDBSnapshotName ,
				@ChildDBCTVersion AS ChildDBCTVersion ,
				@ChildDBSiteInfoHistory AS ChildDBSiteInfoHistory,
				@CoreDBSnapshotName AS CoreDBSnapshotName,  
				@CoreDBCTVersion AS CoreDBCTVersion,
				@CoreDBSiteInfoHistory AS CoreDBSiteInfoHistory,
                @SADBVersion AS DBVersion,
				@SAFSVersion AS FSVersion,
                @SnapshotCreateDate AS SnapshotCreateDate ,
				@SiteCode AS SiteCode ,
				@@SERVERNAME AS DBSnapshotServer,
				@HimTablesDatabase


    END TRY

    BEGIN CATCH
        EXEC rpt.DropDatabaseSnapshot @ChildDBSnapshotName;

		IF @ChildDBSnapshotName <> @CoreDBSnapshotName
			EXEC rpt.DropDatabaseSnapshot @CoreDBSnapshotName;

		RAISERROR ('Somthing went wrong with retrieving snaphot information.  Aborting.', 16, 1) WITH LOG
    END CATCH
	RETURN
END
GO

