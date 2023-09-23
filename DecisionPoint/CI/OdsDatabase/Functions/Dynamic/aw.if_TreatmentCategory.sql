IF OBJECT_ID('aw.if_TreatmentCategory', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_TreatmentCategory;
GO

CREATE FUNCTION aw.if_TreatmentCategory(
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
	t.TreatmentCategoryId,
	t.Category,
	t.Metadata
FROM src.TreatmentCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		TreatmentCategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.TreatmentCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		TreatmentCategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.TreatmentCategoryId = s.TreatmentCategoryId
WHERE t.DmlOperation <> 'D';

GO


