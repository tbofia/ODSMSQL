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
