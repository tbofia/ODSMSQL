IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.Insurer')
	AND NAME = 'IX_InsurerType_InsurerSeq_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_InsurerType_InsurerSeq_OdsCustomerId_OdsPostingGroupAuditId 
ON src.Insurer (InsurerType,InsurerSeq, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Insurer')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.Insurer(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (InsurerType,InsurerSeq);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Insurer')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.Insurer(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,InsurerType,InsurerSeq);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Insurer')
	AND NAME = N'IX_OdsPostingGroupAuditId')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId
ON src.Insurer(OdsPostingGroupAuditId)
INCLUDE (OdsCustomerId,OdsRowIsCurrent,OdsHashbytesValue,InsurerType,InsurerSeq);
GO


