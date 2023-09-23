IF OBJECT_ID('dbo.if_SentryRuleTypeCriteria', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SentryRuleTypeCriteria;
GO

CREATE FUNCTION dbo.if_SentryRuleTypeCriteria(
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
	t.RuleTypeId,
	t.CriteriaId
FROM src.SentryRuleTypeCriteria t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RuleTypeId,
		CriteriaId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SentryRuleTypeCriteria
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RuleTypeId,
		CriteriaId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RuleTypeId = s.RuleTypeId
	AND t.CriteriaId = s.CriteriaId
WHERE t.DmlOperation <> 'D';

GO


