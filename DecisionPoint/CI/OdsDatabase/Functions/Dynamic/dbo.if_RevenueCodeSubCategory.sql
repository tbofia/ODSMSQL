IF OBJECT_ID('dbo.if_RevenueCodeSubCategory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_RevenueCodeSubCategory;
GO

CREATE FUNCTION dbo.if_RevenueCodeSubCategory(
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
	t.RevenueCodeSubcategoryId,
	t.RevenueCodeCategoryId,
	t.Description,
	t.NarrativeInformation
FROM src.RevenueCodeSubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RevenueCodeSubcategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.RevenueCodeSubCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RevenueCodeSubcategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RevenueCodeSubcategoryId = s.RevenueCodeSubcategoryId
WHERE t.DmlOperation <> 'D';

GO


