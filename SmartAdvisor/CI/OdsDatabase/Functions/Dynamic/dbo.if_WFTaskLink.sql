IF OBJECT_ID('dbo.if_WFTaskLink', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_WFTaskLink;
GO

CREATE FUNCTION dbo.if_WFTaskLink(
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
	t.FromTaskSeq,
	t.LinkWhen,
	t.ToTaskSeq
FROM src.WFTaskLink t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		FromTaskSeq,
		LinkWhen,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.WFTaskLink
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		FromTaskSeq,
		LinkWhen) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.FromTaskSeq = s.FromTaskSeq
	AND t.LinkWhen = s.LinkWhen
WHERE t.DmlOperation <> 'D';

GO


