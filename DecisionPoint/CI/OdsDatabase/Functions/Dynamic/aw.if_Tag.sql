IF OBJECT_ID('aw.if_Tag', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_Tag;
GO

CREATE FUNCTION aw.if_Tag(
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
	t.TagId,
	t.NAME,
	t.DateCreated,
	t.DateModified,
	t.CreatedBy,
	t.ModifiedBy
FROM src.Tag t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		TagId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Tag
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		TagId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.TagId = s.TagId
WHERE t.DmlOperation <> 'D';

GO


