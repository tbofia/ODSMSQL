IF OBJECT_ID('rpt.CheckForQueuedPostingGroupRecords') IS NOT NULL
    DROP PROCEDURE rpt.CheckForQueuedPostingGroupRecords
GO

CREATE PROCEDURE rpt.CheckForQueuedPostingGroupRecords ( @PostingGroupId INT )
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @PostingGroupAuditId INT = -1; 

-- Check to see if there are any queued records associated with this group
    SELECT TOP 1
            @PostingGroupAuditId = p.PostingGroupAuditId
    FROM    rpt.PostingGroupAudit p
            INNER JOIN rpt.ProcessAudit e ON p.PostingGroupAuditId = e.PostingGroupAuditId
    WHERE   p.PostingGroupId = @PostingGroupId
            AND e.STATUS <> 'FI'

    IF @PostingGroupAuditId = -1
        RAISERROR ('INFO: No queued posting group records exist.  Let''s create a new posting group.', 0, 1) WITH NOWAIT, LOG
    ELSE
        RAISERROR ('INFO: There are queued posting group records.  Let''s pick up from where we left off.', 0, 1) WITH NOWAIT, LOG

    SELECT  @PostingGroupAuditId AS PostingGroupAuditId

END
GO
