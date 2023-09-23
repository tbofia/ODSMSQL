IF OBJECT_ID('dbo.if_GeneralInterestRuleSetting', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_GeneralInterestRuleSetting;
GO

CREATE FUNCTION dbo.if_GeneralInterestRuleSetting(
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
	t.GeneralInterestRuleBaseTypeId
FROM src.GeneralInterestRuleSetting t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		GeneralInterestRuleBaseTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.GeneralInterestRuleSetting
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		GeneralInterestRuleBaseTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.GeneralInterestRuleBaseTypeId = s.GeneralInterestRuleBaseTypeId
WHERE t.DmlOperation <> 'D';

GO


