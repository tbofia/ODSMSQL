IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.ProviderCluster')
	AND NAME = 'IX_PvdIDNo_OrgOdsCustomerId_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_PvdIDNo_OrgOdsCustomerId_OdsCustomerId_OdsPostingGroupAuditId 
ON src.ProviderCluster (PvdIDNo,OrgOdsCustomerId, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.ProviderCluster')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.ProviderCluster(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (PvdIDNo,OrgOdsCustomerId);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.ProviderCluster')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.ProviderCluster(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,PvdIDNo,OrgOdsCustomerId);
GO

