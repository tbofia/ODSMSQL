IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.PPOProfileNetworksHistory')
	AND NAME = 'IX_PPOProfileNetworksHistory_PPOProfileNetworksHistorySeq_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_PPOProfileNetworksHistory_PPOProfileNetworksHistorySeq_OdsCustomerId_OdsPostingGroupAuditId 
ON src.PPOProfileNetworksHistory (PPOProfileNetworksHistorySeq,PPOProfileSiteCode,PPOProfileID,ProfileRegionSiteCode,ProfileRegionID,NetworkOrder,EffectiveDate, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.PPOProfileNetworksHistory')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.PPOProfileNetworksHistory(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (PPOProfileNetworksHistorySeq,PPOProfileSiteCode,PPOProfileID,ProfileRegionSiteCode,ProfileRegionID,NetworkOrder,EffectiveDate);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.PPOProfileNetworksHistory')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.PPOProfileNetworksHistory(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,PPOProfileNetworksHistorySeq,PPOProfileSiteCode,PPOProfileID,ProfileRegionSiteCode,ProfileRegionID,NetworkOrder,EffectiveDate);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.PPOProfileNetworksHistory')
	AND NAME = N'IX_OdsPostingGroupAuditId')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId
ON src.PPOProfileNetworksHistory(OdsPostingGroupAuditId)
INCLUDE (OdsCustomerId,OdsRowIsCurrent,OdsHashbytesValue,PPOProfileNetworksHistorySeq,PPOProfileSiteCode,PPOProfileID,ProfileRegionSiteCode,ProfileRegionID,NetworkOrder,EffectiveDate);
GO


