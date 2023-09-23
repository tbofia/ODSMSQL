IF OBJECT_ID('dbo.Adjustment3rdPartyEndnoteSubCategory', 'V') IS NOT NULL
    DROP VIEW dbo.Adjustment3rdPartyEndnoteSubCategory;
GO

CREATE VIEW dbo.Adjustment3rdPartyEndnoteSubCategory
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
FROM src.Adjustment3rdPartyEndnoteSubCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


