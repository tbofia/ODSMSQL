IF OBJECT_ID('dbo.if_PPOProfileNetworks', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_PPOProfileNetworks;
GO

CREATE FUNCTION dbo.if_PPOProfileNetworks(
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
FROM src.PPOProfileNetworks t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PPOProfileSiteCode,
		PPOProfileID,
		ProfileRegionSiteCode,
		ProfileRegionID,
		NetworkOrder,
		EffectiveDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PPOProfileNetworks
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PPOProfileSiteCode,
		PPOProfileID,
		ProfileRegionSiteCode,
		ProfileRegionID,
		NetworkOrder,
		EffectiveDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PPOProfileSiteCode = s.PPOProfileSiteCode
	AND t.PPOProfileID = s.PPOProfileID
	AND t.ProfileRegionSiteCode = s.ProfileRegionSiteCode
	AND t.ProfileRegionID = s.ProfileRegionID
	AND t.NetworkOrder = s.NetworkOrder
	AND t.EffectiveDate = s.EffectiveDate
WHERE t.DmlOperation <> 'D';

GO


