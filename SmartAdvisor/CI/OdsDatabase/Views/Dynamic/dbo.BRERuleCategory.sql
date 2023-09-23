IF OBJECT_ID('dbo.BRERuleCategory', 'V') IS NOT NULL
    DROP VIEW dbo.BRERuleCategory;
GO

CREATE VIEW dbo.BRERuleCategory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BRERuleCategoryID
	,CategoryDescription
FROM src.BRERuleCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


