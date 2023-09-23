IF OBJECT_ID('adm.Etl_GenerateReconcilationFile ') IS NOT NULL
    DROP PROCEDURE adm.Etl_GenerateReconcilationFile 
GO

CREATE PROCEDURE adm.Etl_GenerateReconcilationFile  (
@CustomerDatabase VARCHAR(100),
@TargetDatabase VARCHAR(100),
@OutputPath VARCHAR(100))
AS
BEGIN
    -- DECLARE @CustomerDatabase VARCHAR(100) = 'MMedical_Aequicap',@TargetDatabase VARCHAR(100) = 'AcsOds_Test',@OutputPath VARCHAR(100) = '\\qa14nas\CSG-Analytics\OdsFileExtracts\DecisionPoint\Hardening\'
    SET NOCOUNT ON

    DECLARE  @BcpCommand VARCHAR(8000) 
			,@SourceQuery VARCHAR(MAX)
			,@TotalRowsAffected INT = 0
			,@FileName VARCHAR(200) = @CustomerDatabase+'_'+'Reconcilation_file'
			,@FileExtension VARCHAR(5) = 'rcln'
			,@FileColumnDelimiter CHAR(1) = ','

    DECLARE @CommandPromptOutput TABLE(
          CommandPromptOutputId INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED ,
          ResultText VARCHAR(MAX) );

    DECLARE @ErrorWhiteList TABLE (
          CommandPromptOutputId INT);

	SET @SourceQuery = 'SELECT 
							   ProcessId
							  ,TargetTableName
							  ,SnapshotCreateDate
						FROM '+@TargetDatabase+'.adm.ProcessReconciliationDetail
						WHERE CustomerDatabase = '''+@CustomerDatabase+''';'

-- Let's add a backslash if we don't have one.
    IF SUBSTRING(REVERSE(@OutputPath), 1, 1) <> '\'
        SET @OutputPath = @OutputPath + '\';

-- Let's build our bcp command
    SET @BcpCommand = 'bcp "' + REPLACE(REPLACE(@SourceQuery, CHAR(13), ' '), CHAR(10), ' ') + -- newlines are causing issues for bcp
        '" queryout ' + @OutputPath+@CustomerDatabase+'\'+ @FileName + '.' + @FileExtension + ' -c -t "' + @FileColumnDelimiter + '" -S ' + @@SERVERNAME + ' -T';

    BEGIN TRY
        INSERT  INTO @CommandPromptOutput
                EXEC master.sys.xp_cmdshell @BcpCommand;


-- First, let's collect the lines that have the warnings we want to suppress
        INSERT  INTO @ErrorWhiteList
                ( CommandPromptOutputId
                )
                SELECT  CommandPromptOutputId
                FROM    @CommandPromptOutput
                WHERE   ResultText LIKE 'Error%Warning: BCP import with a format file will convert empty strings in delimited columns to NULL%'

-- Now remove them from our command prompt output; we have to also remove the previous lines (which contain the error number)
        DELETE  FROM a
        FROM    @CommandPromptOutput a
        INNER JOIN ( SELECT CommandPromptOutputId - 1 AS CommandPromptOutputId -- Previous line (containing error number)
                     FROM   @ErrorWhiteList
                     UNION ALL
                     SELECT CommandPromptOutputId -- Error description
                     FROM   @ErrorWhiteList ) b ON a.CommandPromptOutputId = b.CommandPromptOutputId;

-- Did we run into any issues on the bcp?
        IF EXISTS ( SELECT  1
                    FROM    @CommandPromptOutput
                    WHERE   ResultText LIKE '%Error%' )
            BEGIN
                RAISERROR ('There is a problem with our bcp command!', 16, 1)
            END

        SELECT  @TotalRowsAffected = CAST(ISNULL(SUBSTRING(ResultText, 1, PATINDEX('%rows copied.%', ResultText) - 1), '0') AS INT)
        FROM    @CommandPromptOutput
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
        FROM    @CommandPromptOutput
        WHERE   ResultText LIKE '%Error%'
        ORDER BY CommandPromptOutputId;

        RAISERROR (@ErrMsg, @ErrSeverity, 1) WITH LOG

        RETURN
    END CATCH

END
GO
