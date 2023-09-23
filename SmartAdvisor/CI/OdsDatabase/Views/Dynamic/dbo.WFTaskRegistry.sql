IF OBJECT_ID('dbo.WFTaskRegistry', 'V') IS NOT NULL
    DROP VIEW dbo.WFTaskRegistry;
GO

CREATE VIEW dbo.WFTaskRegistry
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,WFTaskRegistrySeq
	,EntityTypeCode
	,Description
	,Action
	,SmallImageResID
	,LargeImageResID
	,PersistBefore
	,NAction
FROM src.WFTaskRegistry
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


