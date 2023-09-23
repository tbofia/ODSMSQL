IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.VpnLedger')
	AND NAME = 'IX_TransactionID_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_TransactionID_OdsCustomerId_OdsPostingGroupAuditId 
ON src.VpnLedger (TransactionID, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.VpnLedger')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.VpnLedger(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (TransactionID);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.VpnLedger')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.VpnLedger(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,TransactionID);
GO

