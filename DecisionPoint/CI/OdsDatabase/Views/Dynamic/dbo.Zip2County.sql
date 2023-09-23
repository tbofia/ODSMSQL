IF OBJECT_ID('dbo.Zip2County', 'V') IS NOT NULL
    DROP VIEW dbo.Zip2County;
GO

CREATE VIEW dbo.Zip2County
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Zip
	,County
	,State
FROM src.Zip2County
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


