IF OBJECT_ID('dbo.if_EndnoteSubCategory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_EndnoteSubCategory;
GO

CREATE FUNCTION dbo.if_EndnoteSubCategory(
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
	t.EndnoteSubCategoryId,
	t.Description
FROM src.EndnoteSubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EndnoteSubCategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EndnoteSubCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EndnoteSubCategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EndnoteSubCategoryId = s.EndnoteSubCategoryId
WHERE t.DmlOperation <> 'D';

GO


