IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.PPOProfileNetworks')
	AND NAME = 'IX_PPOProfileNetworks_PPOProfileSiteCode_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_PPOProfileNetworks_PPOProfileSiteCode_OdsCustomerId_OdsPostingGroupAuditId 
ON src.PPOProfileNetworks (PPOProfileSiteCode,PPOProfileID,ProfileRegionSiteCode,ProfileRegionID,NetworkOrder,EffectiveDate, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.PPOProfileNetworks')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.PPOProfileNetworks(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (PPOProfileSiteCode,PPOProfileID,ProfileRegionSiteCode,ProfileRegionID,NetworkOrder,EffectiveDate);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.PPOProfileNetworks')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.PPOProfileNetworks(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,PPOProfileSiteCode,PPOProfileID,ProfileRegionSiteCode,ProfileRegionID,NetworkOrder,EffectiveDate);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.PPOProfileNetworks')
	AND NAME = N'IX_OdsPostingGroupAuditId')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId
ON src.PPOProfileNetworks(OdsPostingGroupAuditId)
INCLUDE (OdsCustomerId,OdsRowIsCurrent,OdsHashbytesValue,PPOProfileSiteCode,PPOProfileID,ProfileRegionSiteCode,ProfileRegionID,NetworkOrder,EffectiveDate);
GO


