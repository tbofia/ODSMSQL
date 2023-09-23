IF OBJECT_ID('dbo.AdjustmentApcEndNoteSubCategory', 'V') IS NOT NULL
    DROP VIEW dbo.AdjustmentApcEndNoteSubCategory;
GO

CREATE VIEW dbo.AdjustmentApcEndNoteSubCategory
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
FROM src.AdjustmentApcEndNoteSubCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


