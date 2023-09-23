IF OBJECT_ID('dbo.AdjustmentOverrideEndNoteSubCategory', 'V') IS NOT NULL
    DROP VIEW dbo.AdjustmentOverrideEndNoteSubCategory;
GO

CREATE VIEW dbo.AdjustmentOverrideEndNoteSubCategory
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
FROM src.AdjustmentOverrideEndNoteSubCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


