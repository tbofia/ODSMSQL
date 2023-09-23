IF OBJECT_ID('dbo.if_SENTRY_PROFILE_RULE', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SENTRY_PROFILE_RULE;
GO

CREATE FUNCTION dbo.if_SENTRY_PROFILE_RULE(
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
	t.ProfileID,
	t.RuleID,
	t.Priority
FROM src.SENTRY_PROFILE_RULE t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProfileID,
		RuleID,
		Priority,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_PROFILE_RULE
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProfileID,
		RuleID,
		Priority) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProfileID = s.ProfileID
	AND t.RuleID = s.RuleID
	AND t.Priority = s.Priority
WHERE t.DmlOperation <> 'D';

GO


