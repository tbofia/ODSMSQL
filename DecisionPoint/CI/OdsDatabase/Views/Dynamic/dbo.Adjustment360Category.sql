IF OBJECT_ID('dbo.Adjustment360Category', 'V') IS NOT NULL
    DROP VIEW dbo.Adjustment360Category;
GO

CREATE VIEW dbo.Adjustment360Category
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Adjustment360CategoryId
	,Name
FROM src.Adjustment360Category
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


