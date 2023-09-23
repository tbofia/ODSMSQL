IF OBJECT_ID('adm.Rpt_DataDump ') IS NOT NULL
    DROP PROCEDURE adm.Rpt_DataDump 
GO

CREATE PROCEDURE adm.Rpt_DataDump  (
@OdsCustomerId INT = 0,
@ProcessId INT  = NULL,
@DBSnapshotName VARCHAR(255) = NULL,
@IsIncremental INT = 1,
@SnapshotServer VARCHAR(255),
@OutputPath VARCHAR(100) ,
@FileExtension VARCHAR(4) ,
@FileColumnDelimiter VARCHAR(2))
AS
BEGIN
    SET NOCOUNT ON
--  DECLARE @OdsCustomerId INT = 0,@ProcessId INT  = 18,  @DBSnapshotName VARCHAR(255) = NULL,@SnapshotServer VARCHAR(255),   @OutputPath VARCHAR(100) = '\\MEDPD-DELL20\OdsFileExtracts',      @FileExtension VARCHAR(4) = 'txt' ,      @FileColumnDelimiter VARCHAR(2) = '|'
	DECLARE  @TargetTableName VARCHAR(255)
			,@TargetSchemaName VARCHAR(50)
			,@SnapshotServerName VARCHAR(255)
			,@DatabaseName VARCHAR(MAX) = DB_NAME()
			,@SnapshotCreateDate DATETIME2
			,@RunPostingGroupAuditId INT
			,@FileName VARCHAR(MAX)
			,@Timestamp VARCHAR(50)
			,@InputSQLSelect VARCHAR(MAX)
			,@OutputSQLSelect VARCHAR(MAX)
			,@NumberOfBatches INT
			,@BatchCounter INT = 0;
	
	IF @IsIncremental = 1 
		SET @RunPostingGroupAuditId = 95207
	-- Remove PII Data from Select Statement
	--INSERT INTO @SnapshotInformation
	EXEC adm.Rpt_RemovePIIData @OdsCustomerId,@ProcessId,@DBSnapshotName,@IsIncremental,@RunPostingGroupAuditId,@InputSQLSelect OUTPUT,@NumberOfBatches OUTPUT; 

	IF @DBSnapshotName IS NULL
	BEGIN
		SET @SnapshotCreateDate = ISNULL(@SnapshotCreateDate,GETDATE());
		SET @SnapshotCreateDate = DATEADD(ms, -DATEPART(ms, @SnapshotCreateDate), @SnapshotCreateDate); -- Remove milliseconds from date
		SET @Timestamp = CONVERT(VARCHAR(8), @SnapshotCreateDate, 112) + RIGHT('0' + CAST(DATEPART(hh, @SnapshotCreateDate) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DATEPART(mi, @SnapshotCreateDate) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DATEPART(ss, @SnapshotCreateDate) AS VARCHAR(2)), 2);
		SET @DBSnapshotName = @DatabaseName + '_' + @Timestamp;

		SET @SnapshotServer = @@SERVERNAME
	END

	SET @TargetTableName  = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId)
	
	SET @FileName = REPLACE(@DBSnapshotName+'_'+@TargetTableName,'\','')

    DECLARE @BcpCommand VARCHAR(8000) , -- xp_cmdshell limitation!
			@TotalRowsAffected INT = 0,
			@SQLScriptSP NVARCHAR(MAX) = '',
			@CoreSiteCode VARCHAR(3);

	IF OBJECT_ID('tempdb..#CommandPromptOutput') IS NOT NULL DROP TABLE #CommandPromptOutput
    CREATE TABLE #CommandPromptOutput(
          CommandPromptOutputId INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED ,
          ResultText VARCHAR(MAX));

	IF OBJECT_ID('tempdb..#ErrorWhiteList') IS NOT NULL DROP TABLE #ErrorWhiteList
    CREATE TABLE #ErrorWhiteList(
          CommandPromptOutputId INT);

		-- Let's add a backslash if we don't have one.
    IF SUBSTRING(REVERSE(@OutputPath), 1, 1) <> '\'
        SET @OutputPath = @OutputPath + '\';

	
	WHILE @BatchCounter = 0 OR @BatchCounter < @NumberOfBatches
	BEGIN
		SET @OutputSQLSelect = REPLACE(@InputSQLSelect,'<BatchId>',@BatchCounter)
		-- Let's build our bcp command
		SET @BcpCommand = 'bcp "' +REPLACE(REPLACE(@OutputSQLSelect, CHAR(13), ' '), CHAR(10), ' ') + -- newlines are causing issues for bcp
			'" queryout ' + @OutputPath + @FileName+CASE WHEN @NumberOfBatches <> 0 THEN '_'+CAST(@BatchCounter AS VARCHAR(5)) ELSE ''END + '.' + @FileExtension + ' -c -t "' + @FileColumnDelimiter + '" -S ' + @SnapshotServer + ' -T';

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

			SELECT  @TotalRowsAffected AS TotalRowsAffected;


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

	SET @BatchCounter = @BatchCounter + 1


	END

END
GO

