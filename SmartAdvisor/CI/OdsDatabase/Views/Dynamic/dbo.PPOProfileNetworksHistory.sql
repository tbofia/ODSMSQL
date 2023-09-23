IF OBJECT_ID('dbo.PPOProfileNetworksHistory', 'V') IS NOT NULL
    DROP VIEW dbo.PPOProfileNetworksHistory;
GO

CREATE VIEW dbo.PPOProfileNetworksHistory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PPOProfileNetworksHistorySeq
	,RecordDeleted
	,LogDateTime
	,loginame
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
FROM src.PPOProfileNetworksHistory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


