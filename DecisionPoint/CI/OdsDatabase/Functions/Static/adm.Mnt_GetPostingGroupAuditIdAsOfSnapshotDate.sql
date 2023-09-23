IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate
GO

CREATE FUNCTION adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate (
@OdsCustomerId INT = 0,
@SnapshotDate DATETIME = NULL)
RETURNS INT
AS
BEGIN
-- DECLARE @OdsCustomerId INT = 0,@SnapshotDate DATETIME = GETDATE()
DECLARE @PostingGroupAuditId INT

SELECT @PostingGroupAuditId = MAX(PostingGroupAuditId)
FROM adm.PostingGroupAudit 
WHERE CustomerId = CASE WHEN ISNULL(@OdsCustomerId,0) = 0 THEN CustomerId ELSE @OdsCustomerId END
	AND CONVERT(VARCHAR(10),SnapshotCreateDate,112) <= CONVERT(VARCHAR(10),ISNULL(@SnapshotDate,GETDATE()),112)
	AND Status = 'FI';

RETURN @PostingGroupAuditId;
END

GO




