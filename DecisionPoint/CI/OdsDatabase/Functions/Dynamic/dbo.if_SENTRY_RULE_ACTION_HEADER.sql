IF OBJECT_ID('dbo.if_SENTRY_RULE_ACTION_HEADER', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SENTRY_RULE_ACTION_HEADER;
GO

CREATE FUNCTION dbo.if_SENTRY_RULE_ACTION_HEADER(
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
	t.EndnoteShort,
	t.EndnoteLong
FROM src.SENTRY_RULE_ACTION_HEADER t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RuleID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_RULE_ACTION_HEADER
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RuleID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RuleID = s.RuleID
WHERE t.DmlOperation <> 'D';

GO


