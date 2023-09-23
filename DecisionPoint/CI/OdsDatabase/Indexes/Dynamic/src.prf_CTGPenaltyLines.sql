IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.prf_CTGPenaltyLines')
	AND NAME = 'IX_CTGPenLineID_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_CTGPenLineID_OdsCustomerId_OdsPostingGroupAuditId 
ON src.prf_CTGPenaltyLines (CTGPenLineID, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.prf_CTGPenaltyLines')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.prf_CTGPenaltyLines(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (CTGPenLineID);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.prf_CTGPenaltyLines')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.prf_CTGPenaltyLines(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,CTGPenLineID);
GO

