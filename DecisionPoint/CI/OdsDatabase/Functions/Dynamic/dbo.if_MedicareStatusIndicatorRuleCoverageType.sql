IF OBJECT_ID('dbo.if_MedicareStatusIndicatorRuleCoverageType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_MedicareStatusIndicatorRuleCoverageType;
GO

CREATE FUNCTION dbo.if_MedicareStatusIndicatorRuleCoverageType(
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
	t.ShortName
FROM src.MedicareStatusIndicatorRuleCoverageType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		ShortName,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.MedicareStatusIndicatorRuleCoverageType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		ShortName) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.MedicareStatusIndicatorRuleId = s.MedicareStatusIndicatorRuleId
	AND t.ShortName = s.ShortName
WHERE t.DmlOperation <> 'D';

GO


