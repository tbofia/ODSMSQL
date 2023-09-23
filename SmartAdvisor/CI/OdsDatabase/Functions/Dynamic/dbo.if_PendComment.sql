IF OBJECT_ID('dbo.if_PendComment', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_PendComment;
GO

CREATE FUNCTION dbo.if_PendComment(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ClientCode,
	t.BillSeq,
	t.PendSeq,
	t.PendCommentSeq,
	t.PendComment,
	t.CreateUserID,
	t.CreateDate,
	t.CreatedByExternalUserName
FROM src.PendComment t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		BillSeq,
		PendSeq,
		PendCommentSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PendComment
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		BillSeq,
		PendSeq,
		PendCommentSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.PendSeq = s.PendSeq
	AND t.PendCommentSeq = s.PendCommentSeq
WHERE t.DmlOperation <> 'D';

GO


