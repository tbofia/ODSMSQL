IF OBJECT_ID('dbo.if_Adjustment360EndNoteSubCategory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Adjustment360EndNoteSubCategory;
GO

CREATE FUNCTION dbo.if_Adjustment360EndNoteSubCategory(
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
	t.ReasonNumber,
	t.SubCategoryId,
	t.EndnoteTypeId
FROM src.Adjustment360EndNoteSubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		EndnoteTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Adjustment360EndNoteSubCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber,
		EndnoteTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
	AND t.EndnoteTypeId = s.EndnoteTypeId
WHERE t.DmlOperation <> 'D';

GO


