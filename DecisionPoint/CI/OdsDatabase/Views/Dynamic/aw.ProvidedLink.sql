IF OBJECT_ID('aw.ProvidedLink', 'V') IS NOT NULL
    DROP VIEW aw.ProvidedLink;
GO

CREATE VIEW aw.ProvidedLink
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProvidedLinkId
	,Title
	,URL
	,OrderIndex
FROM src.ProvidedLink
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


