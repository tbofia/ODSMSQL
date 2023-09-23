IF OBJECT_ID('dbo.Adjustment360OverrideEndNoteSubCategory', 'V') IS NOT NULL
    DROP VIEW dbo.Adjustment360OverrideEndNoteSubCategory;
GO

CREATE VIEW dbo.Adjustment360OverrideEndNoteSubCategory
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
FROM src.Adjustment360OverrideEndNoteSubCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


