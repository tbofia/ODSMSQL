 IF OBJECT_ID('rpt.GenerateDataExtract') IS NOT NULL
    DROP PROCEDURE rpt.GenerateDataExtract
GO

CREATE PROCEDURE rpt.GenerateDataExtract  (
@ProcessStepId INT  = NULL,
@SourceQuery VARCHAR(MAX) ,
@OutputPath VARCHAR(100) ,
@FileName VARCHAR(100) ,
@FileExtension VARCHAR(4) ,
@FileColumnDelimiter VARCHAR(2),
@DBSnapshotName VARCHAR(100) = NULL)
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @BcpCommand VARCHAR(8000) , -- xp_cmdshell limitation!
        @TotalRowsAffected INT = 0,
		@SQLScriptSP NVARCHAR(MAX) = '',
		@BaseFileName VARCHAR(100),
		@TableSchema VARCHAR(50),
		@TotalRowCount BIGINT;

    CREATE TABLE #CommandPromptOutput
        (
          CommandPromptOutputId INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED ,
          ResultText VARCHAR(MAX)
        );

    CREATE TABLE #ErrorWhiteList
        (
          CommandPromptOutputId INT
        );

-- Get Table or View name
	SELECT 	@BaseFileName = P.BaseFileName
	FROM rpt.ProcessStep ps
	INNER JOIN rpt.Process P ON ps.ProcessId = P.ProcessId
	WHERE ps.ProcessStepId = @ProcessStepId

-- Let's add a backslash if we don't have one.
    IF SUBSTRING(REVERSE(@OutputPath), 1, 1) <> '\'
        SET @OutputPath = @OutputPath + '\';

-- Let's build our bcp command
    SET @BcpCommand = 'bcp "' + REPLACE(REPLACE(@SourceQuery, CHAR(13), ' '), CHAR(10), ' ') + -- newlines are causing issues for bcp
        '" queryout ' + @OutputPath + @FileName + '.' + @FileExtension + ' -c -t "' + @FileColumnDelimiter + '" -S ' + @@SERVERNAME + ' -T';

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

-- Get Total Records in source table, will be used to control total records in target table in the ods
		SET @TableSchema =(SELECT TABLE_SCHEMA FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE IN ('BASE TABLE') AND TABLE_NAME = @BaseFileName);
		IF  @TableSchema IS NOT NULL
			SET @SQLScriptSP = '
			BEGIN TRY
				SELECT @TotalRowCount = COUNT(1) FROM '+@DBSnapshotName+'.'+@TableSchema+'.'+@BaseFileName+'
			END TRY
			BEGIN CATCH
				SELECT @TotalRowCount = 0
			END CATCH'
		ELSE
		BEGIN  
			SET @TableSchema =(SELECT TABLE_SCHEMA FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE IN ('VIEW') AND TABLE_NAME = @BaseFileName);
			IF  @TableSchema IS NOT NULL
				SET @SQLScriptSP = '
				BEGIN TRY
					SELECT @TotalRowCount = COUNT(1) FROM '+@DBSnapshotName+'.'+@TableSchema+'.'+@BaseFileName+'
				END TRY
				BEGIN CATCH
					SELECT @TotalRowCount = 0
				END CATCH'
			ELSE 
				SET @SQLScriptSP = 'SELECT @TotalRowCount = 0'
		END 

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
