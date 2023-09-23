IF OBJECT_ID('dbo.if_Adjustment360SubCategory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Adjustment360SubCategory;
GO

CREATE FUNCTION dbo.if_Adjustment360SubCategory(
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
	t.Adjustment360SubCategoryId,
	t.Name,
	t.Adjustment360CategoryId
FROM src.Adjustment360SubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Adjustment360SubCategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Adjustment360SubCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Adjustment360SubCategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Adjustment360SubCategoryId = s.Adjustment360SubCategoryId
WHERE t.DmlOperation <> 'D';

GO


