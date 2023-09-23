IF OBJECT_ID('dbo.EntityType', 'V') IS NOT NULL
    DROP VIEW dbo.EntityType;
GO

CREATE VIEW dbo.EntityType
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,EntityTypeID
	,EntityTypeKey
	,Description
FROM src.EntityType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


