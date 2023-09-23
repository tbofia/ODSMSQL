IF OBJECT_ID('dbo.Adjustment360ApcEndNoteSubCategory', 'V') IS NOT NULL
    DROP VIEW dbo.Adjustment360ApcEndNoteSubCategory;
GO

CREATE VIEW dbo.Adjustment360ApcEndNoteSubCategory
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
FROM src.Adjustment360ApcEndNoteSubCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


