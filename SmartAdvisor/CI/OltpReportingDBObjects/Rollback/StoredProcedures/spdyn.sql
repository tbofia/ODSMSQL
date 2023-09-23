IF OBJECT_ID('rpt.DropDatabaseSnapshot') IS NOT NULL
    DROP PROCEDURE rpt.DropDatabaseSnapshot
GO

CREATE PROCEDURE rpt.DropDatabaseSnapshot    (
@DBSnapshotName VARCHAR(100)  )
AS
BEGIN
-- DECLARE  @DBSnapshotName VARCHAR(100) = ''
    SET NOCOUNT ON

	IF EXISTS(SELECT  1
                    FROM    sys.databases
                    WHERE   name = @DBSnapshotName)
    EXEC ('DROP DATABASE ' + @DBSnapshotName + ';');

END
GO
IF OBJECT_ID('rpt.GenerateDataExtract') IS NOT NULL
    DROP PROCEDURE rpt.GenerateDataExtract
GO

CREATE PROCEDURE rpt.GenerateDataExtract
    (
      @ProcessStepId INT  = NULL,
	  @IsFullExtract BIT = NULL,
	  @PreviousCheckpoint BIGINT = NULL,
	  @CurrentCheckpoint BIGINT = NULL,
	  @IsSnapshot BIT = NULL,
	  @IsHimStatic BIT = NULL,
	  @ChildDBSnapshotName VARCHAR(255) = NULL,
	  @CoreDBSnapshotName VARCHAR(255) = NULL,
	  @SiteCode VARCHAR(3) = NULL,
	  @SourceQuery VARCHAR(MAX) = NULL,
      @OutputPath VARCHAR(100) ,
      @FileName VARCHAR(100) ,
      @FileExtension VARCHAR(4) ,
      @FileColumnDelimiter VARCHAR(2)
    )
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @BcpCommand VARCHAR(8000) , -- xp_cmdshell limitation!
			@TotalRowsAffected INT = 0,
			@TotalRowCount BIGINT,
			@BaseFileName VARCHAR(100),
			@SQLScriptSP NVARCHAR(MAX) = '',
			@CoreSiteCode VARCHAR(3),
			@SiteInfoHistorySeq BIGINT;

    CREATE TABLE #CommandPromptOutput(
          CommandPromptOutputId INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED ,
          ResultText VARCHAR(MAX));

    CREATE TABLE #ErrorWhiteList(
          CommandPromptOutputId INT);

	-- Get CoreDatabase Load status
	SET @SQLScriptSP = 'SELECT TOP 1 @CoreSiteCode = SiteCode ,	@SiteInfoHistorySeq = SiteInfoHistorySeq FROM '+@CoreDBSnapshotName+'.rpt.SnapshotLoadAudit ORDER BY SnapshotLoadAuditId DESC'
	EXEC sp_executesql @SQLScriptSP,N'@CoreSiteCode VARCHAR(3) OUT,	@SiteInfoHistorySeq BIGINT OUT',@CoreSiteCode out, @SiteInfoHistorySeq out;
	

	-- Get Incremental Or Full Query
	IF @SourceQuery IS NULL
		SELECT 	-- If this isn't a full load, let's see if any data has changed by looking at our checkpoints in ProcessStepAudit.
		-- If no data has changed, then make this NULL
			  @SourceQuery = ISNULL(CASE WHEN @IsFullExtract = 0 AND @PreviousCheckpoint = @CurrentCheckpoint THEN NULL
					   ELSE
		-- Otherwise, we're getting the SourceQuery from ProcessStep.FullSql or ProcessStep.IncrementalSql.
		-- There are a couple of keywords that get replaced in the SQL string:
		--		~SNAPSHOT~ - Name of the database snapshot that's being used to generate the data extract.
		--		~PREVIOUSCTVERSION~ - For tables with change tracking enabled, this tells us where the last run left off.
						  REPLACE(REPLACE(REPLACE(CASE WHEN @IsFullExtract = 1 OR (@IsSnapshot = 1 AND  @CoreSiteCode  = @SiteCode AND @SiteInfoHistorySeq = @CurrentCheckpoint) THEN ps.FullSql ELSE ps.IncrementalSql  END
											,'~SNAPSHOT~'
											,CASE WHEN @IsHimStatic = 1 THEN @CoreDBSnapshotName ELSE @ChildDBSnapshotName END)
									, '~PREVIOUSCTVERSION~'
									, ISNULL(@PreviousCheckpoint, '0'))
							,'~SiteCode~'
							,@SiteCode)
					   END, 'SELECT 1 FROM sys.databases WHERE 0 = 1'), -- If NULL, then we'll create a dummy query that can run anywhere on the server to create a file with no rows.
			  @BaseFileName = P.BaseFileName

		FROM rpt.ProcessStep ps
		INNER JOIN rpt.Process P ON ps.ProcessId = P.ProcessId
		WHERE ps.ProcessStepId = @ProcessStepId

	-- Let's add a backslash if we don't have one.
    IF SUBSTRING(REVERSE(@OutputPath), 1, 1) <> '\'
        SET @OutputPath = @OutputPath + '\';

	-- Let's build our bcp command
	IF(LEN(@SourceQuery)>8000)
	BEGIN
		SET @SourceQuery = REPLACE(@SourceQuery,'FROM ','INTO ##'+@FileName+CHAR(13)+CHAR(10)+'FROM ')
		EXEC(@SourceQuery)
		SET @BcpCommand = 'bcp ##'+@FileName+' out ' + @OutputPath + @FileName + '.' + @FileExtension + ' -c -w -t "' + @FileColumnDelimiter + '" -S ' + @@SERVERNAME + ' -T';
	END
	ELSE
		SET @BcpCommand = 'bcp "' + REPLACE(REPLACE(@SourceQuery, CHAR(13), ' '), CHAR(10), ' ') + -- newlines are causing issues for bcp
        '" queryout ' + @OutputPath + @FileName + '.' + @FileExtension + ' -c -w -t "' + @FileColumnDelimiter + '" -S ' + @@SERVERNAME + ' -T';


-- Now, we're going to execute the bcp command via the cmdshell, save the results to #CommandPromptOutput,
-- then look for errors and total row count.
    BEGIN TRY
        INSERT  INTO #CommandPromptOutput
                EXEC master.sys.xp_cmdshell @BcpCommand;

-- MSSQL 2012 is throwing an error when it encounters certain warnings, which is throwing off our error
-- handling below.  Let's remove these if we run into them.
-- First, let's collect the lines that have the warnings we want to suppress
        INSERT  INTO #ErrorWhiteList
                ( CommandPromptOutputId
                )
                SELECT  CommandPromptOutputId
                FROM    #CommandPromptOutput
                WHERE   ResultText LIKE 'Error%Warning: BCP import with a format file will convert empty strings in delimited columns to NULL%'

-- Now remove them from our command prompt output; we have to also remove the previous lines (which contain the error number)
        DELETE  FROM a
        FROM    #CommandPromptOutput a
                INNER JOIN ( SELECT CommandPromptOutputId - 1 AS CommandPromptOutputId -- Previous line (containing error number)
                             FROM   #ErrorWhiteList
                             UNION ALL
                             SELECT CommandPromptOutputId -- Error description
                             FROM   #ErrorWhiteList ) b ON a.CommandPromptOutputId = b.CommandPromptOutputId;

-- Did we run into any issues on the bcp?
        IF EXISTS ( SELECT  1
                    FROM    #CommandPromptOutput
                    WHERE   ResultText LIKE '%Error%' )
            BEGIN
                RAISERROR ('There is a problem with our bcp command!', 16, 1)
            END

        SELECT  @TotalRowsAffected = CAST(ISNULL(SUBSTRING(ResultText, 1, PATINDEX('%rows copied.%', ResultText) - 1), '0') AS INT)
        FROM    #CommandPromptOutput
        WHERE   ResultText LIKE '%rows copied.%';

		IF(LEN(@SourceQuery)>8000) 
		BEGIN 
		SET @SourceQuery = 'DROP TABLE ##'+@FileName
		EXEC(@SourceQuery)
		END

-- Get Total Records in source table, will be used to control total records in target table in the ods
		SET @SQLScriptSP = '
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM sys.objects WHERE type in (''U'',''V'') AND name ='''+@BaseFileName+''')
			BEGIN
				IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE IN (''BASE TABLE'') AND TABLE_NAME='''+@BaseFileName+''')
					SELECT @TotalRowCount = COUNT(1) FROM '+@ChildDBSnapshotName+'.dbo.'+@BaseFileName+'
				ELSE
					SELECT @TotalRowCount = COUNT(1) FROM '+@CoreDBSnapshotName+'.dbo.'+@BaseFileName+'
			END
			ELSE
				SELECT @TotalRowCount = 0;
		END TRY
		BEGIN CATCH
			IF EXISTS(SELECT 1 FROM sys.objects WHERE type in (''U'',''V'') AND name ='''+@BaseFileName+''')
				SELECT @TotalRowCount = COUNT(1) FROM '+@ChildDBSnapshotName+'.dbo.'+@BaseFileName+'
			ELSE
				SELECT @TotalRowCount = 0;
		END CATCH'

		EXEC sp_executesql @SQLScriptSP,N'@TotalRowCount BIGINT OUT',@TotalRowCount OUT;

        SELECT  @TotalRowsAffected AS TotalRowsAffected,@TotalRowCount AS TotalRowCount;

    END TRY

    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION

        DECLARE @ErrMsg NVARCHAR(4000) ,
            @ErrSeverity INT

        SELECT  @ErrMsg = ERROR_MESSAGE() ,
                @ErrSeverity = ERROR_SEVERITY()

        SELECT  @ErrMsg += '; ' + ResultText
        FROM    #CommandPromptOutput
        WHERE   ResultText LIKE '%Error%'
        ORDER BY CommandPromptOutputId;

        RAISERROR (@ErrMsg, @ErrSeverity, 1) WITH LOG

        RETURN
    END CATCH

END
GO




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

IF OBJECT_ID('rpt.GetDataExtractInformation') IS NOT NULL
    DROP PROCEDURE rpt.GetDataExtractInformation
GO

CREATE PROCEDURE rpt.GetDataExtractInformation ( 
@ProcessAuditId INT )
AS
BEGIN
	-- DECLARE @ProcessAuditId INT  = 30,@SiteCode VARCHAR(3) = 'QA1'
    SET NOCOUNT ON;

    DECLARE @ProcessStepAuditId INT ,
        @NextStatus VARCHAR(2)

-- Let's get the next step associated with this process
    SELECT TOP 1
            @ProcessStepAuditId = psa.ProcessStepAuditId
    FROM    rpt.ProcessStep ps
            INNER JOIN rpt.Process p ON ps.ProcessId = p.ProcessId
            INNER JOIN rpt.ProcessStepAudit psa ON ps.ProcessStepId = psa.ProcessStepId
            INNER JOIN rpt.ProcessAudit pa ON psa.ProcessAuditId = pa.ProcessAuditId
            INNER JOIN rpt.PostingGroupAudit pga ON pa.PostingGroupAuditId = pga.PostingGroupAuditId
    WHERE   psa.ProcessAuditId = @ProcessAuditId
            AND psa.CompleteDate IS NULL
    ORDER BY psa.ProcessStepAuditId;

-- Let's make sure we've found the ETL meta data
    IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR ('Oh, oh.  Something went wrong when I tried to look up the ETL meta data.  Aborting.', 16, 1);
            RETURN;
        END

---- Let's find out if there's a subsequent step so we can update ProcessAudit.Status when complete
    SELECT TOP 1
            @NextStatus = RIGHT('00' + CAST(ps.Priority AS VARCHAR(2)), 2)
    FROM    rpt.ProcessStep ps
            INNER JOIN rpt.ProcessStepAudit psa ON ps.ProcessStepId = psa.ProcessStepId
    WHERE   psa.ProcessAuditId = @ProcessAuditId
            AND psa.CompleteDate IS NULL
            AND psa.ProcessStepAuditId > @ProcessStepAuditId
    ORDER BY ProcessStepAuditId;

    SET @NextStatus = ISNULL(@NextStatus, 'FI');

-- Let's return info about this step to the client
    SELECT  psa.ProcessStepAuditId ,
			ps.ProcessStepId,
			det.IsFullExtract,
			psa.PreviousCheckpoint,
			psa.CurrentCheckpoint,
			p.IsSnapshot,
			p.IsHimStatic,
            pga.ChildDBSnapshotName + '_' + p.BaseFileName AS FileName ,
            p.FileExtension ,
            @NextStatus AS NextStatus ,
            pga.DBSnapshotServer ,
            pga.ChildDBSnapshotName ,
			pga.CoreDBSnapshotName,
			p.FileColumnDelimiter
    FROM    rpt.ProcessStep ps
            INNER JOIN rpt.Process p ON ps.ProcessId = p.ProcessId
            INNER JOIN rpt.ProcessStepAudit psa ON ps.ProcessStepId = psa.ProcessStepId
            INNER JOIN rpt.ProcessAudit pa ON psa.ProcessAuditId = pa.ProcessAuditId
            INNER JOIN rpt.PostingGroupAudit pga ON pa.PostingGroupAuditId = pga.PostingGroupAuditId
			INNER JOIN rpt.DataExtractType det ON pga.DataExtractTypeId = det.DataExtractTypeId
    WHERE   psa.ProcessStepAuditId = @ProcessStepAuditId;

END
GO
IF OBJECT_ID('rpt.GetProcessAuditIdFromQueue') IS NOT NULL
    DROP PROCEDURE rpt.GetProcessAuditIdFromQueue
GO

CREATE PROCEDURE rpt.GetProcessAuditIdFromQueue
    (
      @PostingGroupAuditId INT
    )
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @ProcessAuditId INT = -1; 

    BEGIN TRANSACTION

    SELECT TOP 1
            @ProcessAuditId = pa.ProcessAuditId
    FROM    rpt.ProcessAudit pa WITH ( UPDLOCK, ROWLOCK, READPAST )
    WHERE   pa.Status NOT IN ( 'FI', 'ER' )
            AND pa.Status NOT LIKE 'P%'
            AND pa.PostingGroupAuditId = @PostingGroupAuditId
    ORDER BY pa.ProcessAuditId;
/*
-- Now that picking up the record from the queue is done separately from
-- gathering the data, we'll need to have a way to prevent another process from
-- grabbing the same record.  For now, I'll replace the first character of the Status
-- with an 'P' for Pending.
    IF ( @@ROWCOUNT > 0 )
        BEGIN
            UPDATE  rpt.ProcessAudit
            SET     Status = 'P' + SUBSTRING(Status, 2, LEN(Status))
            WHERE   ProcessAuditId = @ProcessAuditId;
        END
*/
    SELECT  @ProcessAuditId AS ProcessAuditId;

    COMMIT TRANSACTION
END
GO
IF OBJECT_ID('rpt.GetReplicaServerName') IS NOT NULL
    DROP PROCEDURE rpt.GetReplicaServerName
GO

CREATE PROCEDURE rpt.GetReplicaServerName
    (
      @DatabaseName VARCHAR(100) = NULL
    )
AS
BEGIN

	-- If an AlwaysOn AG exists for this database, let's use
	-- one of the secondary replicas as the source of our
	-- data extracts.  If not, we'll just use the current server.

	SET @DatabaseName = ISNULL(@DatabaseName, DB_NAME());

    IF NOT EXISTS ( SELECT  1
                    FROM    sys.databases
                    WHERE   name = @DatabaseName )
        RAISERROR ('@DatabaseName does not exist on this server.  Aborting.', 16, 1) WITH LOG

	-- By default, use the current server
    DECLARE @ReplicaServerName SYSNAME = @@SERVERNAME;

    IF SERVERPROPERTY('IsHadrEnabled') = 1
        BEGIN
		-- Get the name of the first secondary replica (by replica_id)
            SELECT TOP 1
                    @ReplicaServerName = rcs.replica_server_name
            FROM    sys.availability_groups_cluster agc
                    INNER JOIN sys.dm_hadr_availability_replica_cluster_states rcs ON rcs.group_id = agc.group_id
                    INNER JOIN sys.dm_hadr_availability_replica_states ars ON ars.replica_id = rcs.replica_id
            WHERE   ars.role = 2 -- SECONDARY
                    AND ars.connected_state = 1 -- CONNECTED
                    AND ars.synchronization_health = 2 -- HEALTHY
			-- Make sure that this database is part of the AG cluster
                    AND EXISTS ( SELECT 1
                                 FROM   sys.dm_hadr_availability_replica_states ars1
                                        INNER JOIN sys.databases d ON ars1.replica_id = d.replica_id
                                 WHERE  d.NAME = @DatabaseName
                                        AND ars1.role = 1 -- PRIMARY
                                        AND ars.group_id = ars1.group_id )
            ORDER BY rcs.replica_id;
        END

    SELECT  @ReplicaServerName AS ReplicaServerName;
END
GO
IF OBJECT_ID('rpt.IsSnapshotStillInUse') IS NOT NULL
    DROP PROCEDURE rpt.IsSnapshotStillInUse
GO

CREATE PROCEDURE rpt.IsSnapshotStillInUse
    (
      @PostingGroupAuditId INT 
    )
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DropSnapshot BIT = 0;

-- Are there any more items in the queue for this posting group?  If not,
-- let's signal that the snapshot can be dropped.
    IF NOT EXISTS ( SELECT TOP 1
                            PostingGroupAuditId
                    FROM    rpt.ProcessAudit
                    WHERE   PostingGroupAuditId = @PostingGroupAuditId
                            AND Status <> 'FI' )
        BEGIN
            SET @DropSnapshot = 1
            UPDATE  rpt.PostingGroupAudit
            SET     Status = 'FI' ,
                    SnapshotDropDate = GETDATE() ,
                    LastChangeDate = GETDATE()
            WHERE   PostingGroupAuditId = @PostingGroupAuditId;
        END

    SELECT  @DropSnapshot AS DropSnapshot;
END
GO

IF OBJECT_ID('rpt.QueuePostingGroup') IS NOT NULL
    DROP PROCEDURE rpt.QueuePostingGroup
GO

CREATE PROCEDURE rpt.QueuePostingGroup
    (
      @PostingGroupId INT ,
      @ChildDBSnapshotName VARCHAR(100) ,
	  @ChildDBCTVersion BIGINT ,
	  @ChildDBSiteInfoHistory INT,
	  @CoreDBSnapshotName VARCHAR(100) ,
	  @CoreDBCTVersion BIGINT ,
	  @CoreDBSiteInfoHistory INT,
      @DBSnapshotServer VARCHAR(100) ,
      @SADBVersion VARCHAR(20) ,
	  @SAFSVersion VARCHAR(20) ,
      @SnapshotCreateDate DATETIME2 ,
      @DataExtractTypeId TINYINT = 0 
    )
AS
BEGIN
	-- DECLARE @PostingGroupId INT = 1,@ChildDBCTVersion BIGINT = 0,@ChildDBSiteInfoHistory INT = 0,@ChildDBSnapshotName VARCHAR(100) ='', @CoreDBCTVersion BIGINT =0,@CoreDBSiteInfoHistory INT = 0,@CoreDBSnapshotName VARCHAR(100) ='', @DBSnapshotServer VARCHAR(100) ='', @SADBVersion VARCHAR(20) ='8.08.0083.8300', @SAFSVersion VARCHAR(20)='8.08.0083.8300' ,  @SnapshotCreateDate DATETIME2 =GETDATE(),  @DataExtractTypeId TINYINT = 0 
    SET NOCOUNT ON;

    DECLARE @PostingGroupAuditId INT,
		@OdsVersion VARCHAR(10),
		@IsFullExtract BIT,
		@FullLoadVersion VARCHAR(20),
		@IsFullExtractDifferential BIT,
		@LatestODSVersion VARCHAR(20)

-- When AppVersion is NULL or empty string , let's set this to '0.0'  (when no
-- value exists for AppVersion, SSIS is passing an empty string). 

    IF @SADBVersion = '' OR @SADBVersion IS NULL
        SET @SADBVersion = '0.0';

    IF @SAFSVersion = '' OR @SAFSVersion IS NULL
        SET @SAFSVersion = '0.0';

-- Let's also store the version of the ODS. We'll pass this information along in the control files.
	SELECT TOP 1
		@OdsVersion = AppVersion
	FROM    rpt.AppVersion
	ORDER BY AppVersionId DESC;

-- Get Top 2 level version numbers
	SELECT @LatestODSVersion = rpt.GetSubstringUpToNthOccurence(@OdsVersion,'.',2)

    BEGIN TRY

        BEGIN TRANSACTION

		SELECT @IsFullExtract = IsFullExtract ,
			   @FullLoadVersion = FullLoadVersion,
			   @IsFullExtractDifferential = ISNULL(IsFullLoadDifferential, 0)
		FROM rpt.DataExtractType 
		WHERE DataExtractTypeId = @DataExtractTypeId;

		-- Let's make sure we have a valid DataExtractTypeId
		IF @@ROWCOUNT = 0
        BEGIN
            SELECT  0 AS PostingGroupAuditId;
			ROLLBACK TRANSACTION
            RETURN;
        END

-- If this is full load and there are no processes with the latest version then dont log any posting groups 
		IF @DataExtractTypeId = 1 AND @FullLoadVersion = '0.0' AND NOT EXISTS (SELECT TOP 1 ProcessId FROM rpt.Process WHERE MinODSVersion = @LatestODSVersion)
		BEGIN
			SELECT  0 AS PostingGroupAuditId;
			ROLLBACK TRANSACTION
            RETURN;
		END

        INSERT  INTO rpt.PostingGroupAudit
                ( PostingGroupId ,
                  DataExtractTypeId ,
                  Status ,
                  ChildDBCTVersion ,
                  ChildDBSnapshotName ,
				  ChildDBSiteInfoHistory,
				  CoreDBCTVersion,
                  CoreDBSnapshotName ,
				  CoreDBSiteInfoHistory,
				  DBSnapshotServer ,
				  SADBVersion ,
				  SAFSVersion ,
                  SnapshotCreateDate ,
                  CreateDate ,
                  LastChangeDate ,
				  OdsVersion 
			    )
                SELECT  @PostingGroupId ,
                        @DataExtractTypeId ,
                        '01' ,
                        @ChildDBCTVersion ,
                        @ChildDBSnapshotName ,
						@ChildDBSiteInfoHistory,
						@CoreDBCTVersion,
						@CoreDBSnapshotName,
						@CoreDBSiteInfoHistory,
                        @DBSnapshotServer ,
						@SADBVersion ,
						@SAFSVersion ,
                        @SnapshotCreateDate ,
                        GETDATE() ,
                        GETDATE() ,
						@OdsVersion

        SET @PostingGroupAuditId = SCOPE_IDENTITY();

        INSERT  INTO rpt.ProcessAudit
                ( PostingGroupAuditId ,
                  ProcessId ,
                  STATUS ,
                  QueueDate ,
                  CreateDate ,
                  LastChangeDate
			    )
                SELECT  @PostingGroupAuditId ,
                        p.ProcessId ,
                        '01' ,
                        GETDATE() ,
                        GETDATE() ,
                        GETDATE()
                FROM    rpt.PostingGroup g
                        INNER JOIN rpt.PostingGroupProcess p ON g.PostingGroupid = p.PostingGroupId
						INNER JOIN rpt.Process p2 ON p.ProcessId = p2.ProcessId
                WHERE   g.PostingGroupId = @PostingGroupId
						AND (
							(@DataExtractTypeId = 1 AND ((@FullLoadVersion = '0.0' AND p2.MinODSVersion = @LatestODSVersion) 
														OR (@FullLoadVersion <> '0.0' AND @IsFullExtractDifferential = 1 AND CAST('/' + REPLACE(p2.MinODSVersion,'.','.1') + '/' AS HIERARCHYID) >= CAST('/' + REPLACE(@FullLoadVersion,'.','.1') + '/' AS HIERARCHYID))
														OR (@FullLoadVersion <> '0.0' AND @IsFullExtractDifferential = 0 AND p2.MinODSVersion = @FullLoadVersion)))
							OR
							@DataExtractTypeId <> 1
						)
                ORDER BY p.Priority ,
                        p.ProcessId;                 
				    	
        INSERT  INTO rpt.ProcessStepAudit
                ( ProcessAuditId ,
                  ProcessStepId ,
                  PreviousCheckpoint ,
                  CurrentCheckpoint ,
                  CreateDate ,
                  LastChangeDate
			    )
                SELECT  pa.ProcessAuditId ,
                        ec.ProcessStepId ,
                        ISNULL(cp.PreviousCheckpoint, 0) ,
						/** Current Checkpoint Logic **/
						-- If someone kicks off a full extract, and it isn't the initial extract, let's keep the old checkpoint.
						-- This way, the next incremental extract will include all changes since the last incremental.
                        CASE WHEN @IsFullExtract = 1
                                  AND ISNULL(cp.PreviousCheckpoint, 0) > 0 THEN ISNULL(cp.PreviousCheckpoint, 0)
						-- If the minimum application version is '0.0', then we want to keep the old checkpoint (which should be 0).
						-- These records will just dump out empty files, so we don't want to move forward until the customer upgrades
						-- to a supported version of the application.
							 WHEN ec.MinAppVersion = '0.0' THEN ISNULL(cp.PreviousCheckpoint, 0)
						-- We've got several checkpoint types:
						-- 1) rpt.Process.IsSnapshot = 0: Change Tracking
						-- 2) rpt.Process.IsSnapshot = 1: Snapshots either Core Snapshots or Child Database Snapshots
                             WHEN p.IsSnapshot = 0 AND p.IsHimStatic = 0 THEN @ChildDBCTVersion
							 WHEN p.IsSnapshot = 0 AND p.IsHimStatic = 1 THEN @CoreDBCTVersion
                             WHEN p.IsSnapshot = 1
                                  AND p.IsHimStatic = 0 
								  AND p.ProductKey = 'SmartAdvisor' THEN @ChildDBSiteInfoHistory
                             WHEN p.IsSnapshot = 1
                                  AND p.IsHimStatic = 1 THEN @CoreDBSiteInfoHistory
                             ELSE NULL
                        END ,
                        GETDATE() ,
                        GETDATE()
                FROM    rpt.ProcessAudit pa
                        INNER JOIN rpt.Process p ON pa.ProcessId = p.ProcessId
						-- Let's use the HIERARCHYID data type to compare application versions.
                        INNER JOIN ( SELECT ec1.ProcessId ,
                                            MAX(CAST('/' + REPLACE(ec1.MinAppVersion,'.','.1') + '/' AS HIERARCHYID)) AS MinAppVersion
                                     FROM   rpt.ProcessStep ec1
									 INNER JOIN rpt.Process p1 ON ec1.ProcessId = p1.ProcessId
									 -- We want to get the greatest (relative to supported AppVersion) from ProcessStep records
									 -- that's less than or equal to our current product version.
									 WHERE CAST('/' + REPLACE(ec1.MinAppVersion,'.','.1') + '/' AS HIERARCHYID) <= CAST('/' + CASE WHEN p1.ProductKey = 'SmartAdvisor' THEN REPLACE(@SADBVersion,'.','.1')
																											END + '/' AS HIERARCHYID)
                                     GROUP BY ec1.ProcessId ) a ON p.ProcessId = a.ProcessId
                        INNER JOIN rpt.ProcessStep ec ON a.ProcessId = ec.ProcessId
                                                         AND a.MinAppVersion = CAST('/' + REPLACE(ec.MinAppVersion,'.','.1') + '/' AS HIERARCHYID)
                        LEFT OUTER JOIN rpt.ProcessCheckpoint cp ON p.ProcessId = cp.ProcessId
                WHERE   pa.PostingGroupAuditId = @PostingGroupAuditId
                ORDER BY ec.Priority ,
                        pa.ProcessAuditId;       

-- Let's make sure we've retrieved some ETL steps.
        IF @@ROWCOUNT = 0
            RAISERROR ('Insert into rpt.ProcessStep failed.  Are you sure the AppVersion is correct?', 16, 1) WITH LOG

        SELECT  @PostingGroupAuditId AS PostingGroupAuditId;

        COMMIT TRANSACTION

    END TRY

    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION

        DECLARE @ErrMsg NVARCHAR(4000) ,
            @ErrSeverity INT

        SELECT  @ErrMsg = ERROR_MESSAGE() ,
                @ErrSeverity = ERROR_SEVERITY()

        RAISERROR (@ErrMsg, @ErrSeverity, 1) WITH LOG

        
    END CATCH
RETURN
END
GO
IF OBJECT_ID('rpt.SetHimTablesLoadStatus') IS NOT NULL
    DROP PROCEDURE rpt.SetHimTablesLoadStatus
GO

CREATE PROCEDURE rpt.SetHimTablesLoadStatus  (
@DatabaseName VARCHAR(100) = NULL,
@DataExtractTypeId INT = 0)
AS
BEGIN
--DECLARE @DatabaseName VARCHAR(100) = 'ODS_dB_1_Child',@DataExtractTypeId INT = 0
    DECLARE @DBSnapshotServer VARCHAR(100),
		@SiteInfoHistorySeqAudit BIGINT, 
		@SiteInfoHistorySeq BIGINT,
		@HimTablesDatabase VARCHAR(100),
		@HimTablesLoadStatus CHAR(2),
		@CoreDatabaseName VARCHAR(100),
		@SiteCode VARCHAR(3),
        @Sql NVARCHAR(MAX) ,
        @SpExecuteSql NVARCHAR(MAX);

-- Audit the Load of Him tables so other customers using the same core know they have alreay been loaded
	SET @SpExecuteSql = @DatabaseName + '.sys.sp_executesql' -- This allows me to make calls on our snapshot without changing the db context
	EXEC @SpExecuteSql N'SELECT TOP 1	@CoreDatabaseName = SiteInfo.ShareFSDb, @SiteCode = SiteInfo.SiteCode	FROM dbo.SiteInfo',  N'@CoreDatabaseName VARCHAR(100) OUTPUT,@SiteCode VARCHAR(3) OUTPUT', @CoreDatabaseName = @CoreDatabaseName OUTPUT,@SiteCode = @SiteCode OUTPUT;;

	SET @HimTablesDatabase = (SELECT CASE WHEN EXISTS (SELECT  1 FROM    sys.databases  WHERE   name = @CoreDatabaseName) THEN @CoreDatabaseName ELSE @DatabaseName  END)

	SET @SpExecuteSql = @HimTablesDatabase + '.sys.sp_executesql' -- This allows me to make calls on our snapshot without changing the db context

	SET @Sql = '
	SELECT TOP 1 @SiteInfoHistorySeq = SiteInfoHistorySeq 
	FROM '+@HimTablesDatabase+'.dbo.SiteInfoHistory ORDER BY SiteInfoHistory.SiteInfoHistorySeq DESC

	SELECT TOP 1 @SiteInfoHistorySeqAudit = SiteInfoHistorySeq,@HimTablesLoadStatus = Status
	FROM '+@HimTablesDatabase+'.rpt.SnapshotLoadAudit ORDER BY SnapshotLoadAuditId DESC'

	EXEC @SpExecuteSql @Sql,N'@SiteInfoHistorySeqAudit BIGINT OUT,	@SiteInfoHistorySeq BIGINT OUT,@HimTablesLoadStatus CHAR(2) OUT',@SiteInfoHistorySeqAudit out, @SiteInfoHistorySeq out,@HimTablesLoadStatus out;
	-- Only Create new entry if last was loaded successfully
	IF (ISNULL(@SiteInfoHistorySeqAudit,0) <> @SiteInfoHistorySeq AND ISNULL(@HimTablesLoadStatus,'FI') = 'FI' AND (SELECT IsFullExtract FROM rpt.DataExtractType WHERE DataExtractTypeId = @DataExtractTypeId) <> 1)
	BEGIN
		SET @Sql = 'INSERT INTO '+@HimTablesDatabase+'.rpt.SnapshotLoadAudit VALUES ('''+@SiteCode+''','+CAST(@SiteInfoHistorySeq AS VARCHAR(MAX))+',(SELECT MAX(AppVersion) FROM rpt.AppVersion),''01'',GETDATE())'
		EXEC(@Sql)
	END
END
GO


IF OBJECT_ID('rpt.SetIncompletePostingGroupAuditIdStatus') IS NOT NULL
    DROP PROCEDURE rpt.SetIncompletePostingGroupAuditIdStatus
GO

CREATE PROCEDURE rpt.SetIncompletePostingGroupAuditIdStatus ( 
@PostingGroupAuditId INT, 
@ChildDBSnapshotName VARCHAR(100),
@CoreDBSnapshotName VARCHAR(100))
AS
BEGIN
-- DECLARE @PostingGroupAuditId INT
    SET NOCOUNT ON

    DECLARE  @Status VARCHAR(2); 

	-- Check to see if there are any queued records associated with this group
    SELECT   @Status = p.Status
    FROM    rpt.PostingGroupAudit p
    WHERE   p.PostingGroupAuditId = @PostingGroupAuditId

	-- Set Status to Er... Error
	IF @Status <> 'FI'
	BEGIN
		UPDATE rpt.PostingGroupAudit
		SET Status = 'Er'
		WHERE PostingGroupAuditId = @PostingGroupAuditId;

		INSERT INTO rpt.PostingGroupAuditError
		VALUES(@PostingGroupAuditId,'DS','Snapshot[s] created for this postinggroupauditid no longer exist[s].',GETDATE());

		-- Reset Change Tracking checkpoint to last completed
		UPDATE pc
		SET    pc.PreviousCheckpoint = psa.PreviousCheckpoint
		FROM   rpt.ProcessCheckpoint pc
				INNER JOIN rpt.ProcessAudit pa ON pc.ProcessId = pa.ProcessId
				INNER JOIN rpt.ProcessStepAudit psa ON pa.ProcessAuditId = psa.ProcessAuditId
		WHERE  pa.PostingGroupAuditId = @PostingGroupAuditId;

		-- Attemp to drop snapshots in case one existed but not the other
		EXEC rpt.DropDatabaseSnapshot @ChildDBSnapshotName
		EXEC rpt.DropDatabaseSnapshot @CoreDBSnapshotName
	END

END
GO
IF OBJECT_ID('rpt.UpdateHimTablesLoadStatus') IS NOT NULL
    DROP PROCEDURE rpt.UpdateHimTablesLoadStatus
GO

CREATE PROCEDURE rpt.UpdateHimTablesLoadStatus  (
@HimTablesDatabase VARCHAR(100),
@SiteCode VARCHAR(3)
    )
AS
BEGIN
--DECLARE @HimTablesDatabase VARCHAR(100)='ODS_dB_1_Core',@SiteCode VARCHAR(3)='QA1'
    SET NOCOUNT ON
	
    EXEC ('UPDATE '+@HimTablesDatabase+'.rpt.SnapshotLoadAudit SET Status = ''FI'' WHERE SiteCode = '''+@SiteCode+''';');

END
GO



IF OBJECT_ID('rpt.UpdateJobStatus') IS NOT NULL
    DROP PROCEDURE rpt.UpdateJobStatus
GO

CREATE PROCEDURE rpt.UpdateJobStatus (
@ProcessAuditId INT ,
@Status VARCHAR(2) ,
@ProcessStepAuditId INT = -1 ,
@TotalRowsAffected INT = 0,
@TotalRowCount BIGINT)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @PreviousCheckpoint BIGINT ,
        @ProcessId SMALLINT

    BEGIN TRANSACTION

-- Update rpt.ProcessAudit
    UPDATE  rpt.ProcessAudit
    SET     Status = @Status ,
			TotalRowCount = @TotalRowCount,
            ExtractDate = CASE WHEN @Status = 'FI' THEN GETDATE()
                               ELSE NULL
                          END ,
            LastChangeDate = GETDATE()
    WHERE   ProcessAuditId = @ProcessAuditId;

-- Update rpt.ProcessStepAudit, if info available
    IF @ProcessStepAuditId <> -1
        BEGIN
    -- Let's get the CurrentCheckpoint and ProcessId associated with this @ProcessStepAuditId
            SELECT  @PreviousCheckpoint = psa.CurrentCheckpoint ,
                    @ProcessId = pa.ProcessId
            FROM    rpt.ProcessAudit pa
                    INNER JOIN rpt.ProcessStepAudit psa ON pa.ProcessAuditId = psa.ProcessAuditId
            WHERE   psa.ProcessStepAuditId = @ProcessStepAuditId;

            IF EXISTS ( SELECT  1
                        FROM    rpt.ProcessCheckpoint
                        WHERE   ProcessId = @ProcessId )
                UPDATE  rpt.ProcessCheckpoint
                SET     PreviousCheckpoint = @PreviousCheckpoint ,
                        LastChangeDate = GETDATE()
                WHERE   ProcessId = @ProcessId
                        AND PreviousCheckpoint < @PreviousCheckpoint; -- Let's only update when checkpoint changes
            ELSE
                INSERT  INTO rpt.ProcessCheckpoint
                        ( ProcessId ,
                          PreviousCheckpoint ,
                          LastChangeDate
                        )
                VALUES  ( @ProcessId ,
                          @PreviousCheckpoint ,
                          GETDATE()
                        );

    -- Now, let's update rpt.ProcessStepAudit
            UPDATE  rpt.ProcessStepAudit
            SET     TotalRowsAffected = @TotalRowsAffected ,
                    CompleteDate = GETDATE() ,
                    LastChangeDate = GETDATE()
            WHERE   ProcessStepAuditId = @ProcessStepAuditId;
        END

    COMMIT TRANSACTION
END
GO
IF OBJECT_ID('rpt.CheckForQueuedPostingGroupRecords') IS NOT NULL
    DROP PROCEDURE rpt.CheckForQueuedPostingGroupRecords
GO

CREATE PROCEDURE rpt.CheckForQueuedPostingGroupRecords ( @PostingGroupId INT )
AS
BEGIN
    SET NOCOUNT ON

    DECLARE  @PostingGroupAuditId INT = -1
			,@ChildDBSnapshotName VARCHAR(100)
			,@CoreDBSnapshotName VARCHAR(100); 

-- Check to see if there are any queued records associated with this group
    SELECT TOP 1
             @PostingGroupAuditId = p.PostingGroupAuditId
			,@ChildDBSnapshotName = p.ChildDBSnapshotName
			,@CoreDBSnapshotName = p.CoreDBSnapshotName
    FROM    rpt.PostingGroupAudit p
            INNER JOIN rpt.ProcessAudit e ON p.PostingGroupAuditId = e.PostingGroupAuditId
    WHERE   p.PostingGroupId = @PostingGroupId
            AND e.STATUS = '01'
	ORDER BY p.PostingGroupAuditId DESC

	IF @PostingGroupAuditId <> -1 AND (NOT EXISTS(SELECT  1
												FROM    sys.databases
												WHERE   name = @ChildDBSnapshotName) OR NOT EXISTS(SELECT  1
																									FROM    sys.databases
																									WHERE   name = @CoreDBSnapshotName))
	BEGIN
		EXEC rpt.SetIncompletePostingGroupAuditIdStatus @PostingGroupAuditId,@ChildDBSnapshotName,@CoreDBSnapshotName
		-- Reset to No incomplete Postinggroupauditids
		SET @PostingGroupAuditId = -1
	END

    IF @PostingGroupAuditId = -1
        RAISERROR ('INFO: No queued posting group records exist.  Let''s create a new posting group.', 0, 1) WITH NOWAIT, LOG
    ELSE
		RAISERROR ('INFO: There are queued posting group records.  Let''s pick up from where we left off.', 0, 1) WITH NOWAIT, LOG

    SELECT  @PostingGroupAuditId AS PostingGroupAuditId

END
GO
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
IF OBJECT_ID('rpt.GenerateControlFile') IS NOT NULL
    DROP PROCEDURE rpt.GenerateControlFile
GO

CREATE PROCEDURE rpt.GenerateControlFile
    (
      @PostingGroupAuditId INT,
      @OutputPath Varchar(200)

    )
AS
BEGIN
    SET NOCOUNT ON
	
    DECLARE @SourceQuery VARCHAR(MAX) ,
        @FileName VARCHAR(100) ,
        @FileExtension VARCHAR(4) = 'ctl' ,
        @FileColumnDelimiter VARCHAR(2) = ',' ,
        @OdsVersion VARCHAR(10) ,
		@DatabaseName VARCHAR(100) = DB_NAME()


 SELECT		@FileName = pga.ChildDBSnapshotName + '_' + RIGHT('0000000000' + CAST(PostingGroupAuditId AS VARCHAR(10)), 10) + '_' +
			det.DataExtractTypeCode ,
			@OdsVersion = pga.OdsVersion
    FROM    rpt.PostingGroupAudit pga
            INNER JOIN rpt.PostingGroup pg ON pga.PostingGroupId = pg.PostingGroupId
			INNER JOIN rpt.DataExtractType det ON pga.DataExtractTypeId = det.DataExtractTypeId
    WHERE   pga.PostingGroupAuditId = @PostingGroupAuditId;
	
	

    SET @SourceQuery = 'SELECT ''' + @FileName + '.ctl'+ '''  ,pga.PostingGroupAuditId,pga.CoreDBSiteInfoHistory,pga.SnapshotCreateDate, pga.ChildDBSnapshotName + ''_'' + p.BaseFileName + ''.txt'' AS FileName ,p.BaseFileName,
            psa.TotalRowsAffected,pa.TotalRowCount, ''' + @OdsVersion + '''
    FROM    ' + @DatabaseName + '.rpt.ProcessStepAudit psa
            INNER JOIN ' + @DatabaseName + '.rpt.ProcessAudit pa ON psa.ProcessAuditId = pa.ProcessAuditId
            INNER JOIN ' + @DatabaseName + '.rpt.Process p ON pa.ProcessId = p.ProcessId
            INNER JOIN ' + @DatabaseName + '.rpt.PostingGroupAudit pga ON pa.PostingGroupAuditId = pga.PostingGroupAuditId 
    WHERE   pga.PostingGroupAuditId = ' + CAST(@PostingGroupAuditId AS VARCHAR(10));    

    EXEC rpt.GenerateDataExtract @SourceQuery = @SourceQuery, @OutputPath = @OutputPath, @FileName = @FileName, @FileExtension = @FileExtension, @FileColumnDelimiter = @FileColumnDelimiter

END
GO
