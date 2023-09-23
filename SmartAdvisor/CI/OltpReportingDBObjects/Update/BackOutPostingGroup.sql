SET XACT_ABORT ON;
SET NOCOUNT ON;

BEGIN TRANSACTION;

DECLARE @PostingGroupAuditId INT ,
        @Status VARCHAR(2) ,
        @Message VARCHAR(100);

-- What was the last posting group?
SELECT @PostingGroupAuditId = MAX(PostingGroupAuditId)
FROM   rpt.PostingGroupAudit;

-- What was the status of this posting group?
SELECT @Status = Status
FROM   rpt.PostingGroupAudit
WHERE  PostingGroupAuditId = @PostingGroupAuditId;

IF @Status = 'FI' OR @Status IS NULL
    BEGIN
        PRINT 'Nothing to do here.  Aborting...';
        ROLLBACK TRANSACTION;
        RETURN;
    END;

-- Do we have any extracts created after the posting group we're trying to rollback?
IF EXISTS (   SELECT TOP 1 1
              FROM   rpt.PostingGroupAudit
              WHERE  PostingGroupAuditId > @PostingGroupAuditId )
    BEGIN
        RAISERROR('You can''t back out this posting group without backing out subsequent posting groups!  Aborting...', 16, 1) WITH LOG;
        ROLLBACK TRANSACTION;
        RETURN;
    END;

UPDATE pc
SET    pc.PreviousCheckpoint = psa.PreviousCheckpoint
FROM   rpt.ProcessCheckpoint pc
       INNER JOIN rpt.ProcessAudit pa ON pc.ProcessId = pa.ProcessId
       INNER JOIN rpt.ProcessStepAudit psa ON pa.ProcessAuditId = psa.ProcessAuditId
WHERE  pa.PostingGroupAuditId = @PostingGroupAuditId;

DELETE FROM a
FROM  rpt.ProcessStepAudit a
      INNER JOIN rpt.ProcessAudit b ON a.ProcessAuditId = b.ProcessAuditId
      INNER JOIN rpt.PostingGroupAudit c ON b.PostingGroupAuditId = c.PostingGroupAuditId
WHERE c.PostingGroupAuditId = @PostingGroupAuditId;

DELETE FROM b
FROM  rpt.ProcessAudit b
      INNER JOIN rpt.PostingGroupAudit c ON b.PostingGroupAuditId = c.PostingGroupAuditId
WHERE c.PostingGroupAuditId = @PostingGroupAuditId;

DELETE FROM c
FROM  rpt.PostingGroupAudit c
WHERE c.PostingGroupAuditId = @PostingGroupAuditId;

SET @Message = 'Successfully removed PostingGroupAuditId ' + CAST(@PostingGroupAuditId AS VARCHAR(20)) + ' from database ' + DB_NAME();
PRINT @Message;

COMMIT TRANSACTION;

