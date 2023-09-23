IF OBJECT_ID('dbo.RevenueCodeCategory', 'V') IS NOT NULL
    DROP VIEW dbo.RevenueCodeCategory;
GO

CREATE VIEW dbo.RevenueCodeCategory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,RevenueCodeCategoryId
	,Description
	,NarrativeInformation
FROM src.RevenueCodeCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


