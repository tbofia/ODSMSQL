IF OBJECT_ID('dbo.if_DeductibleRuleCriteriaCoverageType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_DeductibleRuleCriteriaCoverageType;
GO

CREATE FUNCTION dbo.if_DeductibleRuleCriteriaCoverageType(
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
	t.CoverageType
FROM src.DeductibleRuleCriteriaCoverageType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DeductibleRuleCriteriaId,
		CoverageType,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.DeductibleRuleCriteriaCoverageType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DeductibleRuleCriteriaId,
		CoverageType) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DeductibleRuleCriteriaId = s.DeductibleRuleCriteriaId
	AND t.CoverageType = s.CoverageType
WHERE t.DmlOperation <> 'D';

GO


