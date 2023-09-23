IF OBJECT_ID('dbo.RevenueCodeSubCategory', 'V') IS NOT NULL
    DROP VIEW dbo.RevenueCodeSubCategory;
GO

CREATE VIEW dbo.RevenueCodeSubCategory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,RevenueCodeSubcategoryId
	,RevenueCodeCategoryId
	,Description
	,NarrativeInformation
FROM src.RevenueCodeSubCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


