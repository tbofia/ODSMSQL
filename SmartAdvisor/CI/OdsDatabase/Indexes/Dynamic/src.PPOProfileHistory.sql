IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.PPOProfileHistory')
	AND NAME = 'IX_PPOProfileHistorySeq_SiteCode_PPOProfileID_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_PPOProfileHistorySeq_SiteCode_PPOProfileID_OdsCustomerId_OdsPostingGroupAuditId 
ON src.PPOProfileHistory (PPOProfileHistorySeq,SiteCode,PPOProfileID, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.PPOProfileHistory')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.PPOProfileHistory(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (PPOProfileHistorySeq,SiteCode,PPOProfileID);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.PPOProfileHistory')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.PPOProfileHistory(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,PPOProfileHistorySeq,SiteCode,PPOProfileID);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.PPOProfileHistory')
	AND NAME = N'IX_OdsPostingGroupAuditId')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId
ON src.PPOProfileHistory(OdsPostingGroupAuditId)
INCLUDE (OdsCustomerId,OdsRowIsCurrent,OdsHashbytesValue,PPOProfileHistorySeq,SiteCode,PPOProfileID);
GO


