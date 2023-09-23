IF OBJECT_ID('dbo.EndnoteSubCategory', 'V') IS NOT NULL
    DROP VIEW dbo.EndnoteSubCategory;
GO

CREATE VIEW dbo.EndnoteSubCategory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,EndnoteSubCategoryId
	,Description
FROM src.EndnoteSubCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


