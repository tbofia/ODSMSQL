IF OBJECT_ID('dbo.if_MedicareStatusIndicatorRule', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_MedicareStatusIndicatorRule;
GO

CREATE FUNCTION dbo.if_MedicareStatusIndicatorRule(
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
	t.MedicareStatusIndicatorRuleId,
	t.MedicareStatusIndicatorRuleName,
	t.StatusIndicator,
	t.StartDate,
	t.EndDate,
	t.Endnote,
	t.EditActionId,
	t.Comments
FROM src.MedicareStatusIndicatorRule t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.MedicareStatusIndicatorRule
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		MedicareStatusIndicatorRuleId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.MedicareStatusIndicatorRuleId = s.MedicareStatusIndicatorRuleId
WHERE t.DmlOperation <> 'D';

GO


