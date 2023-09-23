IF OBJECT_ID('dbo.ProviderCluster', 'V') IS NOT NULL
    DROP VIEW dbo.ProviderCluster;
GO

CREATE VIEW dbo.ProviderCluster
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProviderSubSet
	,ProviderSeq
	,OrgOdsCustomerId
	,MitchellProviderKey
	,ProviderClusterKey
	,ProviderType
FROM src.ProviderCluster
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


