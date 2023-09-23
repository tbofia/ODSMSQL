IF OBJECT_ID('rpt.GetDataExtractInformation') IS NOT NULL
    DROP PROCEDURE rpt.GetDataExtractInformation
GO

CREATE PROCEDURE rpt.GetDataExtractInformation ( @ProcessAuditId INT )
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ProcessStepAuditId INT ,
			@NextStatus VARCHAR(2),
			@DatabaseName VARCHAR(100) = DB_NAME();

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
	-- If this isn't a full load, let's see if any data has changed by looking at our checkpoints in ProcessStepAudit.
	-- If no data has changed, then make this NULL
            ISNULL(CASE WHEN det.IsFullExtract = 0
                      AND psa.PreviousCheckpoint = psa.CurrentCheckpoint THEN NULL
                 ELSE
	-- Otherwise, we're getting the SourceQuery from ProcessStep.FullSql or ProcessStep.IncrementalSql.
	-- There are a couple of keywords that get replaced in the SQL string:
	--		~SNAPSHOT~ - Name of the database snapshot that's being used to generate the data extract.
	--		~PREVIOUSCTVERSION~ - For tables with change tracking enabled, this tells us where the last run left off.
                      REPLACE(REPLACE(REPLACE(CASE WHEN det.IsFullExtract = 1
                                                OR p.IsSnapshot = 1 THEN ps.FullSql
                                           ELSE ps.IncrementalSql
                                      END
									  ,'~SNAPSHOT~', pga.DBSnapshotName)
									  ,'~PREVIOUSCTVERSION~', ISNULL(psa.PreviousCheckpoint, '0'))
									  ,'FROM '+pga.DBSnapshotName,CASE WHEN p.TargetPlatform = 'SnowFlake' THEN ' ,'''+@DatabaseName+''' AS SourceDatabase'+CHAR(10)+'FROM '+pga.DBSnapshotName ELSE 'FROM '+pga.DBSnapshotName END)
            END, 'SELECT 1 FROM sys.databases WHERE 0 = 1') AS SourceQuery , -- If NULL, then we'll create a dummy query that can run anywhere on the server to create a file with no rows.
            p.FileExtension ,
            @NextStatus AS NextStatus ,
            pga.DBSnapshotServer ,
            pga.DBSnapshotName ,
			p.FileColumnDelimiter,
			ps.ProcessStepId,
			CASE WHEN SUBSTRING(REVERSE(T.OutputPath), 1, 1) <> '\'  THEN T.OutputPath + '\' ELSE T.OutputPath END + @DatabaseName AS OutputPath,
			pga.DataExtractTypeId
    FROM    rpt.ProcessStep ps
            INNER JOIN rpt.Process p ON ps.ProcessId = p.ProcessId
			INNER JOIN rpt.TargetPlatformDropLocation T ON P.TargetPlatform = T.TargetPlatform
            INNER JOIN rpt.ProcessStepAudit psa ON ps.ProcessStepId = psa.ProcessStepId
            INNER JOIN rpt.ProcessAudit pa ON psa.ProcessAuditId = pa.ProcessAuditId
            INNER JOIN rpt.PostingGroupAudit pga ON pa.PostingGroupAuditId = pga.PostingGroupAuditId
			INNER JOIN rpt.DataExtractType det ON pga.DataExtractTypeId = det.DataExtractTypeId
    WHERE   psa.ProcessStepAuditId = @ProcessStepAuditId;

END
GO
