IF OBJECT_ID('dbo.if_SENTRY_RULE', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SENTRY_RULE;
GO

CREATE FUNCTION dbo.if_SENTRY_RULE(
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
	t.RuleID,
	t.Name,
	t.Description,
	t.CreatedBy,
	t.CreationDate,
	t.PostFixNotation,
	t.Priority,
	t.RuleTypeID
FROM src.SENTRY_RULE t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RuleID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_RULE
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RuleID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RuleID = s.RuleID
WHERE t.DmlOperation <> 'D';

GO


