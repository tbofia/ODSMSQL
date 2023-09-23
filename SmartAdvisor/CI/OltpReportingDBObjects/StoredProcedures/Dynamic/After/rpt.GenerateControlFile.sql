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
