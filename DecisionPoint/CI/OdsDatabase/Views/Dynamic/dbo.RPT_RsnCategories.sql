IF OBJECT_ID('dbo.RPT_RsnCategories', 'V') IS NOT NULL
    DROP VIEW dbo.RPT_RsnCategories;
GO

CREATE VIEW dbo.RPT_RsnCategories
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CategoryIdNo
	,CatDesc
	,Priority
FROM src.RPT_RsnCategories
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


