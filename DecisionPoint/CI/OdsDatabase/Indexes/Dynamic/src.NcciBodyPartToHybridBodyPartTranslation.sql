IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.NcciBodyPartToHybridBodyPartTranslation')
	AND NAME = 'IX_NcciBodyPartId_HybridBodyPartId_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_NcciBodyPartId_HybridBodyPartId_OdsCustomerId_OdsPostingGroupAuditId 
ON src.NcciBodyPartToHybridBodyPartTranslation (NcciBodyPartId,HybridBodyPartId, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.NcciBodyPartToHybridBodyPartTranslation')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.NcciBodyPartToHybridBodyPartTranslation(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (NcciBodyPartId,HybridBodyPartId);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.NcciBodyPartToHybridBodyPartTranslation')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.NcciBodyPartToHybridBodyPartTranslation(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,NcciBodyPartId,HybridBodyPartId);
GO

