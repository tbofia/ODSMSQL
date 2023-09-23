IF OBJECT_ID('dbo.if_SENTRY_RULE_CONDITION', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SENTRY_RULE_CONDITION;
GO

CREATE FUNCTION dbo.if_SENTRY_RULE_CONDITION(
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
	t.GroupFlag,
	t.CriteriaID,
	t.Operator,
	t.ConditionValue,
	t.AndOr,
	t.UdfConditionId
FROM src.SENTRY_RULE_CONDITION t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RuleID,
		LineNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_RULE_CONDITION
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


