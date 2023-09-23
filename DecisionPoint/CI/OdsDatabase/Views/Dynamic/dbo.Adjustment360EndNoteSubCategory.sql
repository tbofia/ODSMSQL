IF OBJECT_ID('dbo.Adjustment360EndNoteSubCategory', 'V') IS NOT NULL
    DROP VIEW dbo.Adjustment360EndNoteSubCategory;
GO

CREATE VIEW dbo.Adjustment360EndNoteSubCategory
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
	,EndnoteTypeId
FROM src.Adjustment360EndNoteSubCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


