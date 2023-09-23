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
