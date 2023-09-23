IF OBJECT_ID('rpt.GetProcessAuditIdFromQueue') IS NOT NULL
    DROP PROCEDURE rpt.GetProcessAuditIdFromQueue
GO

CREATE PROCEDURE rpt.GetProcessAuditIdFromQueue
    (
      @PostingGroupAuditId INT
    )
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @ProcessAuditId INT = -1; 

    BEGIN TRANSACTION

    SELECT TOP 1
            @ProcessAuditId = pa.ProcessAuditId
    FROM    rpt.ProcessAudit pa WITH ( UPDLOCK, ROWLOCK, READPAST )
    WHERE   pa.Status NOT IN ( 'FI', 'ER' )
            AND pa.Status NOT LIKE 'P%'
            AND pa.PostingGroupAuditId = @PostingGroupAuditId
    ORDER BY pa.ProcessAuditId;
/*
-- Now that picking up the record from the queue is done separately from
-- gathering the data, we'll need to have a way to prevent another process from
-- grabbing the same record.  For now, I'll replace the first character of the Status
-- with an 'P' for Pending.
    IF ( @@ROWCOUNT > 0 )
        BEGIN
            UPDATE  rpt.ProcessAudit
            SET     Status = 'P' + SUBSTRING(Status, 2, LEN(Status))
            WHERE   ProcessAuditId = @ProcessAuditId;
        END
*/
    SELECT  @ProcessAuditId AS ProcessAuditId;

    COMMIT TRANSACTION
END
GO
