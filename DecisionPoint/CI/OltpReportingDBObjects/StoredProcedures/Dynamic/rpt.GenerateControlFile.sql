IF OBJECT_ID('rpt.GenerateControlFile') IS NOT NULL
    DROP PROCEDURE rpt.GenerateControlFile
GO

CREATE PROCEDURE rpt.GenerateControlFile(
@PostingGroupAuditId INT,
@SourceDatabase VARCHAR(50),
@returnvalue INT OUTPUT)
AS
BEGIN
-- DECLARE @PostingGroupAuditId INT=4,@SourceDatabase VARCHAR(50)='MMedical_QBE',@returnvalue INT = 0
    SET NOCOUNT ON
	
    DECLARE @SourceQuery VARCHAR(MAX) ,
			@FileName VARCHAR(100) ,
			@FileExtension VARCHAR(4) = 'ctl' ,
			@FileColumnDelimiter VARCHAR(2) = ',' ,
			@AcsOdsVersion VARCHAR(10) ,
			@DatabaseName VARCHAR(100) = DB_NAME()

     SET @returnvalue = 0
	 IF NOT EXISTS ( SELECT TOP 1
                            PostingGroupAuditId
                    FROM    rpt.ProcessAudit
                    WHERE   PostingGroupAuditId = @PostingGroupAuditId
                            AND Status <> 'FI' )

     -- Only Create control file if all processes completed successfully
	 BEGIN

		SELECT	@FileName = pga.DBSnapshotName + '_' + RIGHT('0000000000' + CAST(PostingGroupAuditId AS VARCHAR(10)), 10) + '_' +
				det.DataExtractTypeCode ,
				@AcsOdsVersion = pga.AcsOdsVersion
		FROM    rpt.PostingGroupAudit pga
				INNER JOIN rpt.PostingGroup pg ON pga.PostingGroupId = pg.PostingGroupId
				INNER JOIN rpt.DataExtractType det ON pga.DataExtractTypeId = det.DataExtractTypeId
		WHERE   pga.PostingGroupAuditId = @PostingGroupAuditId;
	

		-- Setup Cursor to go through all processes to remove customer
		DECLARE @TargetPlatform VARCHAR(100),@OutputPath VARCHAR(100)
		DECLARE db_cursor CURSOR FOR  
		SELECT DISTINCT T.TargetPlatform,CASE WHEN SUBSTRING(REVERSE(T.OutputPath), 1, 1) <> '\'  THEN T.OutputPath + '\' ELSE T.OutputPath END + @DatabaseName AS OutputPath
		FROM rpt.TargetPlatformDropLocation T
		INNER JOIN rpt.Process P ON P.TargetPlatform = T.TargetPlatform

		OPEN db_cursor   
		FETCH NEXT FROM db_cursor INTO @TargetPlatform,@OutputPath

		WHILE @@FETCH_STATUS = 0   
		BEGIN 

		SET @SourceQuery = 
		   'SELECT ''' + @FileName + '.ctl'+ ''''+CHAR(10)+ CHAR(9)+
					CASE WHEN @TargetPlatform = 'Snowflake' THEN ',''ACS'' AS Product'+CHAR(10)+CHAR(9)+',CASE WHEN pga.DataExtractTypeId = 1 THEN ''FULL'' WHEN pga.DataExtractTypeId = 0 THEN ''INCR'' WHEN pga.DataExtractTypeId = 2 THEN ''SNAP'' END'+CHAR(10)+CHAR(9) ELSE ''+CHAR(10)+CHAR(9) END +
					CASE WHEN @TargetPlatform <> 'Snowflake' THEN ',pga.PostingGroupAuditId' ELSE ',NULL' END +CHAR(10)+ CHAR(9)+
					',pga.SnapshotCreateDate'+CHAR(10)+ CHAR(9)+
					CASE WHEN @TargetPlatform = 'Snowflake' THEN ',p.BaseFileName' ELSE '' END +CHAR(10)+ CHAR(9)+
					CASE WHEN @TargetPlatform = 'Snowflake' THEN ',pa.TotalNumberOfFiles'+CHAR(10)+ CHAR(9)+',fa.FileNumber '+CHAR(10)+ CHAR(9) ELSE ''+CHAR(10)+ CHAR(9) END +
					',pga.DBSnapshotName + ''_'' + p.BaseFileName+''_''+CAST(fa.FileNumber AS VARCHAR(10))+''_''+ ''.txt'' AS FileName '+CHAR(10)+ CHAR(9)+
					CASE WHEN @TargetPlatform <> 'Snowflake' THEN ',p.BaseFileName' ELSE '' END +CHAR(10)+ CHAR(9)+
					',fa.TotalRecordsInFile'+CHAR(10)+ CHAR(9)+
					',pa.TotalRowCount'+CHAR(10)+ CHAR(9)+
					CASE WHEN @TargetPlatform = 'Snowflake' THEN ',pga.PostingGroupAuditId ' ELSE '' END+CHAR(10)+ CHAR(9)+
					CASE WHEN @TargetPlatform = 'Snowflake' THEN ',(SELECT MAX(PostingGroupAuditId) FROM ' + @DatabaseName + '.rpt.PostingGroupAudit WHERE PostingGroupAuditId < ' + CAST(@PostingGroupAuditId AS VARCHAR(10)) +' AND Status = ''FI'')' ELSE '' END +CHAR(10)+ CHAR(9)+
					',''' + @AcsOdsVersion + ''''+CHAR(10)+ CHAR(9)+
					CASE WHEN @TargetPlatform = 'Snowflake' THEN ',fa.FileSize '+CHAR(10) ELSE ''+CHAR(10) END +

			'FROM    ' + @DatabaseName + '.rpt.ProcessStepAudit psa'+CHAR(10)+
			'INNER JOIN ' + @DatabaseName + '.rpt.ProcessAudit pa ON psa.ProcessAuditId = pa.ProcessAuditId'+CHAR(10)+
			'INNER JOIN ' + @DatabaseName + '.rpt.Process p ON pa.ProcessId = p.ProcessId AND P.TargetPlatform = '''+@TargetPlatform+''''+CHAR(10)+
			'INNER JOIN ' + @DatabaseName + '.rpt.PostingGroupAudit pga ON pa.PostingGroupAuditId = pga.PostingGroupAuditId '+CHAR(10)+
			'INNER JOIN ' + @DatabaseName + '.rpt.ProcessFileAudit fa ON pa.ProcessAuditId = fa.ProcessAuditId'+CHAR(10)+
			'WHERE   pga.PostingGroupAuditId = ' + CAST(@PostingGroupAuditId AS VARCHAR(10));   
	
		BEGIN TRY
			EXEC rpt.GenerateDataExtract @SourceQuery = @SourceQuery, @OutputPath = @OutputPath, @FileName = @FileName, @FileExtension = @FileExtension, @FileColumnDelimiter = @FileColumnDelimiter
		END TRY
		BEGIN CATCH
		-- Set failure return value if error in generating control file
			SET @returnvalue = 1
		END CATCH
		
		FETCH NEXT FROM db_cursor INTO @TargetPlatform,@OutputPath

		END

		CLOSE db_cursor   
		DEALLOCATE db_cursor
	END
	-- Set failure return value if did not create control file due to incomplete processes
	ELSE
		SET @returnvalue = 1

END
GO

