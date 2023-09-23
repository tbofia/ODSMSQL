IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.UDFLevelChangeTracking')
	AND NAME = 'IX_UDFLevelChangeTrackingId_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_UDFLevelChangeTrackingId_OdsCustomerId_OdsPostingGroupAuditId 
ON src.UDFLevelChangeTracking (UDFLevelChangeTrackingId, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.UDFLevelChangeTracking')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.UDFLevelChangeTracking(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (UDFLevelChangeTrackingId);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.UDFLevelChangeTracking')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.UDFLevelChangeTracking(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,UDFLevelChangeTrackingId);
GO

