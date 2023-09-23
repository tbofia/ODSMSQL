IF OBJECT_ID('dbo.ProviderSys', 'V') IS NOT NULL
    DROP VIEW dbo.ProviderSys;
GO

CREATE VIEW dbo.ProviderSys
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProviderSubset
	,ProviderSubSetDesc
	,ProviderAccess
	,TaxAddrRequired
	,AllowDummyProviders
	,CascadeUpdatesOnImport
	,RootExtIDOverrideDelimiter
FROM src.ProviderSys
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


