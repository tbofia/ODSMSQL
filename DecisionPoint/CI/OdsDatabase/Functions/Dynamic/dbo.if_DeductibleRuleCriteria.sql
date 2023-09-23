IF OBJECT_ID('dbo.if_DeductibleRuleCriteria', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_DeductibleRuleCriteria;
GO

CREATE FUNCTION dbo.if_DeductibleRuleCriteria(
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
	t.DeductibleRuleCriteriaId,
	t.PricingRuleDateCriteriaId,
	t.StartDate,
	t.EndDate
FROM src.DeductibleRuleCriteria t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DeductibleRuleCriteriaId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.DeductibleRuleCriteria
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DeductibleRuleCriteriaId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DeductibleRuleCriteriaId = s.DeductibleRuleCriteriaId
WHERE t.DmlOperation <> 'D';

GO


