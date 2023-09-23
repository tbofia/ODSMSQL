IF OBJECT_ID('dbo.ExtractCat', 'V') IS NOT NULL
    DROP VIEW dbo.ExtractCat;
GO

CREATE VIEW dbo.ExtractCat
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CatIdNo
	,Description
FROM src.ExtractCat
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


