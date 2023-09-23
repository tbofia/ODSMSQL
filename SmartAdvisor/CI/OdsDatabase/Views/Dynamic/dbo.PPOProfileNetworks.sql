IF OBJECT_ID('dbo.PPOProfileNetworks', 'V') IS NOT NULL
    DROP VIEW dbo.PPOProfileNetworks;
GO

CREATE VIEW dbo.PPOProfileNetworks
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PPOProfileSiteCode
	,PPOProfileID
	,ProfileRegionSiteCode
	,ProfileRegionID
	,NetworkOrder
	,PPONetworkID
	,SearchLogic
	,Verification
	,EffectiveDate
	,TerminationDate
	,JurisdictionInd
	,JurisdictionInsurerSeq
	,JurisdictionUseOnly
	,PPOSSTinReq
	,PPOSSLicReq
	,DefaultExtendedSearches
	,DefaultExtendedFilters
	,SeveredTies
	,POS
FROM src.PPOProfileNetworks
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


