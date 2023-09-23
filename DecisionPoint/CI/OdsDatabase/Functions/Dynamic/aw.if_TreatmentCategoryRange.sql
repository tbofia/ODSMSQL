IF OBJECT_ID('aw.if_TreatmentCategoryRange', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_TreatmentCategoryRange;
GO

CREATE FUNCTION aw.if_TreatmentCategoryRange(
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
	t.TreatmentCategoryRangeId,
	t.TreatmentCategoryId,
	t.StartRange,
	t.EndRange
FROM src.TreatmentCategoryRange t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		TreatmentCategoryRangeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.TreatmentCategoryRange
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		TreatmentCategoryRangeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.TreatmentCategoryRangeId = s.TreatmentCategoryRangeId
WHERE t.DmlOperation <> 'D';

GO


