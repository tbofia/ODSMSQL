IF OBJECT_ID('dbo.AdjustmentEndNoteSubCategory', 'V') IS NOT NULL
    DROP VIEW dbo.AdjustmentEndNoteSubCategory;
GO

CREATE VIEW dbo.AdjustmentEndNoteSubCategory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ReasonNumber
	,SubCategoryId
FROM src.AdjustmentEndNoteSubCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


