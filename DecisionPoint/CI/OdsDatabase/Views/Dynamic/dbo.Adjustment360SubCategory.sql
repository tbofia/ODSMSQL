IF OBJECT_ID('dbo.Adjustment360SubCategory', 'V') IS NOT NULL
    DROP VIEW dbo.Adjustment360SubCategory;
GO

CREATE VIEW dbo.Adjustment360SubCategory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Adjustment360SubCategoryId
	,Name
	,Adjustment360CategoryId
FROM src.Adjustment360SubCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


