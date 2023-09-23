BEGIN TRAN
BEGIN TRY

	UPDATE psa
	SET processStepid = ps1.ProcessStepId
	FROM rpt.processStepAudit psa
	JOIN rpt.processAudit pa
		ON psa.ProcessAuditId = pa.processauditid
	JOIN rpt.processStep ps1
		ON pa.ProcessId = ps1.ProcessId 
		AND ps1.MinAppVersion = '8.3'
	LEFT JOIN rpt.processStep ps2
		ON psa.ProcessStepId = ps2.processStepid
	WHERE ps2.processStepid IS NULL;
	
	COMMIT TRAN;
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
	PRINT 'Something went wrong. Rollback.';
END CATCH

--Update DataExtractType table for New Customer Only
DECLARE @ErrMsg nvarchar(4000) = N'',@ErrSeverity INT;

BEGIN TRAN 
BEGIN TRY 
	IF NOT EXISTS (SELECT 1 
				FROM rpt.PostingGroupAudit 
				WHERE DataExtractTypeId = 1 AND Status = 'FI')
	BEGIN
		UPDATE rpt.DataExtractType  
		SET FullLoadVersion = '1.0', IsFullLoadDifferential = 1  
		WHERE DataExtractTypeId = 1;
	END
	COMMIT TRAN 
END TRY
BEGIN CATCH
	SELECT @ErrMsg = ERROR_MESSAGE(),
		   @ErrSeverity = ERROR_SEVERITY()
	ROLLBACK TRAN;
	RAISERROR(@ErrMsg, @ErrSeverity, 1); 
END CATCH 

-- This was originally configured as a dynamic table. 
-- It's dev static, so let's disable Change Tracking and reset the checkpoint value.
SET XACT_ABORT ON;
IF EXISTS
(
    SELECT object_id
    FROM sys.change_tracking_tables
    WHERE object_id = OBJECT_ID('dbo.UdfDataFormat')
)
BEGIN
    BEGIN TRANSACTION;

       -- Disable Change Tracking
    ALTER TABLE dbo.UdfDataFormat DISABLE CHANGE_TRACKING;
       
       -- Reset the checkpoint for this table
    UPDATE pc
    SET pc.PreviousCheckpoint = 0
    FROM rpt.ProcessCheckpoint pc
        INNER JOIN rpt.Process p
            ON p.ProcessId = pc.ProcessId
    WHERE p.BaseFileName = 'UdfDataFormat';

    COMMIT TRANSACTION;
END;
GO

IF EXISTS
(
    SELECT object_id
    FROM sys.change_tracking_tables
    WHERE object_id = OBJECT_ID('dbo.VpnProcessFlagType')
)
BEGIN
    BEGIN TRANSACTION;

       -- Disable Change Tracking
    ALTER TABLE dbo.VpnProcessFlagType DISABLE CHANGE_TRACKING;
       
       -- Reset the checkpoint for this table
    UPDATE pc
    SET pc.PreviousCheckpoint = 0
    FROM rpt.ProcessCheckpoint pc
        INNER JOIN rpt.Process p
            ON p.ProcessId = pc.ProcessId
    WHERE p.BaseFileName = 'VpnProcessFlagType';

    COMMIT TRANSACTION;
END;
GO

IF EXISTS
(
    SELECT object_id
    FROM sys.change_tracking_tables
    WHERE object_id = OBJECT_ID('dbo.VpnSavingTransactionType')
)
BEGIN
    BEGIN TRANSACTION;

       -- Disable Change Tracking
    ALTER TABLE dbo.VpnSavingTransactionType DISABLE CHANGE_TRACKING;
       
       -- Reset the checkpoint for this table
    UPDATE pc
    SET pc.PreviousCheckpoint = 0
    FROM rpt.ProcessCheckpoint pc
        INNER JOIN rpt.Process p
            ON p.ProcessId = pc.ProcessId
    WHERE p.BaseFileName = 'VpnSavingTransactionType';

    COMMIT TRANSACTION;
END;
GO

