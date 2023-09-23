IF OBJECT_ID('dbo.if_SENTRY_RULE_ACTION_DETAIL', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SENTRY_RULE_ACTION_DETAIL;
GO

CREATE FUNCTION dbo.if_SENTRY_RULE_ACTION_DETAIL(
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
	t.LineNumber,
	t.ActionID,
	t.ActionValue
FROM src.SENTRY_RULE_ACTION_DETAIL t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RuleID,
		LineNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_RULE_ACTION_DETAIL
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RuleID,
		LineNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RuleID = s.RuleID
	AND t.LineNumber = s.LineNumber
WHERE t.DmlOperation <> 'D';

GO


