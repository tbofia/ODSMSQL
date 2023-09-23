IF OBJECT_ID('dbo.if_Adjustment360ApcEndNoteSubCategory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Adjustment360ApcEndNoteSubCategory;
GO

CREATE FUNCTION dbo.if_Adjustment360ApcEndNoteSubCategory(
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
	t.SubCategoryId
FROM src.Adjustment360ApcEndNoteSubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Adjustment360ApcEndNoteSubCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
WHERE t.DmlOperation <> 'D';

GO


