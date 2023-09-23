IF OBJECT_ID('dbo.if_PPOProfileNetworksHistory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_PPOProfileNetworksHistory;
GO

CREATE FUNCTION dbo.if_PPOProfileNetworksHistory(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.PPOProfileNetworksHistorySeq,
	t.RecordDeleted,
	t.LogDateTime,
	t.loginame,
	t.PPOProfileSiteCode,
	t.PPOProfileID,
	t.ProfileRegionSiteCode,
	t.ProfileRegionID,
	t.NetworkOrder,
	t.PPONetworkID,
	t.SearchLogic,
	t.Verification,
	t.EffectiveDate,
	t.TerminationDate,
	t.JurisdictionInd,
	t.JurisdictionInsurerSeq,
	t.JurisdictionUseOnly,
	t.PPOSSTinReq,
	t.PPOSSLicReq,
	t.DefaultExtendedSearches,
	t.DefaultExtendedFilters,
	t.SeveredTies,
	t.POS
FROM src.PPOProfileNetworksHistory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PPOProfileNetworksHistorySeq,
		PPOProfileSiteCode,
		PPOProfileID,
		ProfileRegionSiteCode,
		ProfileRegionID,
		NetworkOrder,
		EffectiveDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PPOProfileNetworksHistory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PPOProfileNetworksHistorySeq,
		PPOProfileSiteCode,
		PPOProfileID,
		ProfileRegionSiteCode,
		ProfileRegionID,
		NetworkOrder,
		EffectiveDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PPOProfileNetworksHistorySeq = s.PPOProfileNetworksHistorySeq
	AND t.PPOProfileSiteCode = s.PPOProfileSiteCode
	AND t.PPOProfileID = s.PPOProfileID
	AND t.ProfileRegionSiteCode = s.ProfileRegionSiteCode
	AND t.ProfileRegionID = s.ProfileRegionID
	AND t.NetworkOrder = s.NetworkOrder
	AND t.EffectiveDate = s.EffectiveDate
WHERE t.DmlOperation <> 'D';

GO


