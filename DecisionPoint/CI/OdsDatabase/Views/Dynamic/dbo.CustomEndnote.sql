IF OBJECT_ID('dbo.CustomEndnote', 'V') IS NOT NULL
    DROP VIEW dbo.CustomEndnote;
GO

CREATE VIEW dbo.CustomEndnote
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CustomEndnote
	,ShortDescription
	,LongDescription
FROM src.CustomEndnote
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


