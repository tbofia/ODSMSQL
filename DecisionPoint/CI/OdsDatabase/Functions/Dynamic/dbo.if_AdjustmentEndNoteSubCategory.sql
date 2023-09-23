IF OBJECT_ID('dbo.if_AdjustmentEndNoteSubCategory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_AdjustmentEndNoteSubCategory;
GO

CREATE FUNCTION dbo.if_AdjustmentEndNoteSubCategory(
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
FROM src.AdjustmentEndNoteSubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AdjustmentEndNoteSubCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
WHERE t.DmlOperation <> 'D';

GO


