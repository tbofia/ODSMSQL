IF OBJECT_ID('rpt.CheckForQueuedPostingGroupRecords') IS NOT NULL
    DROP PROCEDURE rpt.CheckForQueuedPostingGroupRecords
GO

CREATE PROCEDURE rpt.CheckForQueuedPostingGroupRecords ( 
@PostingGroupId INT, 
@SourceServer VARCHAR(100),
@SourceDatabase VARCHAR(100)
)
AS
BEGIN
-- DECLARE @PostingGroupId INT = 1, @SourceServer VARCHAR(100) = 'QAOAG04ANTV\MEDQA1',@SourceDatabase VARCHAR(100) = 'MMedical_Germania'
    SET NOCOUNT ON

    DECLARE  @PostingGroupAuditId INT = -1
			,@PostingGroupAuditStatus VARCHAR(2)
			,@DBSnapshotName VARCHAR(100)
			,@cmd VARCHAR(500)
			,@unameparam_ VARCHAR(50) = '/E'
			,@pwdparam_ VARCHAR(50) = ''
			,@SqlQuery VARCHAR(8000) = '';
	    
	DECLARE @CommandPromptOutput TABLE(
          CommandPromptOutputId INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED ,
          ResultText VARCHAR(MAX));

-- Check to see if there are any queued records associated with this group
    SELECT TOP 1
             @PostingGroupAuditId = p.PostingGroupAuditId
			,@DBSnapshotName = p.DBSnapshotName
			,@PostingGroupAuditStatus = P.Status
    FROM    rpt.PostingGroupAudit p
            INNER JOIN rpt.ProcessAudit e ON p.PostingGroupAuditId = e.PostingGroupAuditId
    WHERE   p.PostingGroupId = @PostingGroupId
            AND e.STATUS = '01'
	ORDER BY p.PostingGroupAuditId DESC

	-- If there exists a postinggroup that is incomplete and snapshot no longer exists, lets log error and do some cleanup
	IF @PostingGroupAuditId <> -1 AND @PostingGroupAuditStatus = '01' AND (NOT EXISTS(SELECT  1
												FROM    sys.databases
												WHERE   name = @DBSnapshotName))
	BEGIN
		
		SET @SqlQuery = 'EXEC rpt.SetIncompletePostingGroupAuditIdStatus '+CAST(@PostingGroupAuditId AS VARCHAR(10))+','+@DBSnapshotName+';'
		SET @cmd = 'sqlcmd -S '+@SourceServer+' '+@unameparam_+' '+@pwdparam_+' -d '+@SourceDatabase+' -Q"'+REPLACE(@SqlQuery,CHAR(13)+CHAR(10),' ')+'"'

		INSERT INTO @CommandPromptOutput
		EXEC MASTER..xp_cmdshell @cmd

		-- Did we run into any issues reseting Posting group audit
        IF EXISTS ( SELECT  1
                    FROM    @CommandPromptOutput
                    WHERE   ResultText LIKE '%Error%' )
           RAISERROR ('There is a problem resetting failed posting group Audit!', 16, 1)        

		-- Reset to No incomplete Postinggroupauditids i.e. set up so can create new posting group audit
		SET @PostingGroupAuditId = -1
	END

	-- If the latest posting group audit exists in any other status than incomplete, we have to create a new one.
	IF @PostingGroupAuditStatus <> '01'
		SET @PostingGroupAuditId = -1

    IF @PostingGroupAuditId = -1
        RAISERROR ('INFO: No queued posting group records exist.  Let''s create a new posting group.', 0, 1) WITH NOWAIT, LOG
    ELSE
		RAISERROR ('INFO: There are queued posting group records.  Let''s pick up from where we left off.', 0, 1) WITH NOWAIT, LOG

    SELECT  @PostingGroupAuditId AS PostingGroupAuditId

END
GO

