IF OBJECT_ID('dbo.if_SENTRY_ACTION_CATEGORY', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SENTRY_ACTION_CATEGORY;
GO

CREATE FUNCTION dbo.if_SENTRY_ACTION_CATEGORY(
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
	t.ActionCategoryIDNo,
	t.Description
FROM src.SENTRY_ACTION_CATEGORY t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ActionCategoryIDNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_ACTION_CATEGORY
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ActionCategoryIDNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ActionCategoryIDNo = s.ActionCategoryIDNo
WHERE t.DmlOperation <> 'D';

GO


