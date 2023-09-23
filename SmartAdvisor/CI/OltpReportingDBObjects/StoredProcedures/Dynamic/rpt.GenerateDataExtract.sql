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




