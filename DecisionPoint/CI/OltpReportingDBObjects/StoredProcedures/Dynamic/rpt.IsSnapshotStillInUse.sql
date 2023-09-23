IF OBJECT_ID('rpt.IsSnapshotStillInUse') IS NOT NULL
    DROP PROCEDURE rpt.IsSnapshotStillInUse
GO

CREATE PROCEDURE rpt.IsSnapshotStillInUse
    (
      @PostingGroupAuditId INT 
    )
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DropSnapshot BIT = 0;

-- Are there any more items in the queue for this posting group?  If not,
-- let's signal that the snapshot can be dropped.
    IF NOT EXISTS ( SELECT TOP 1
                            PostingGroupAuditId
                    FROM    rpt.ProcessAudit
                    WHERE   PostingGroupAuditId = @PostingGroupAuditId
                            AND Status <> 'FI' )
        BEGIN
            SET @DropSnapshot = 1
            UPDATE  rpt.PostingGroupAudit
            SET     Status = 'FI' ,
                    SnapshotDropDate = GETDATE() ,
                    LastChangeDate = GETDATE()
            WHERE   PostingGroupAuditId = @PostingGroupAuditId;
        END

    SELECT  @DropSnapshot AS DropSnapshot;
END
GO

