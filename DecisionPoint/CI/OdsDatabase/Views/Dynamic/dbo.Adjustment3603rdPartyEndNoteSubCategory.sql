IF OBJECT_ID('dbo.Adjustment3603rdPartyEndNoteSubCategory', 'V') IS NOT NULL
    DROP VIEW dbo.Adjustment3603rdPartyEndNoteSubCategory;
GO

CREATE VIEW dbo.Adjustment3603rdPartyEndNoteSubCategory
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
FROM src.Adjustment3603rdPartyEndNoteSubCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


