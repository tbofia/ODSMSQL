IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.UDFClaimant')
	AND NAME = 'IX_CmtIdNo_UDFIdNo_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_CmtIdNo_UDFIdNo_OdsCustomerId_OdsPostingGroupAuditId 
ON src.UDFClaimant (CmtIdNo,UDFIdNo, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.UDFClaimant')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.UDFClaimant(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (CmtIdNo,UDFIdNo);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.UDFClaimant')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.UDFClaimant(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,CmtIdNo,UDFIdNo);
GO

