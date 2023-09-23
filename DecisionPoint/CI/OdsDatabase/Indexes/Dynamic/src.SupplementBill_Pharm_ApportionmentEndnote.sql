IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.SupplementBill_Pharm_ApportionmentEndnote')
	AND NAME = 'IX_BillId_SequenceNumber_LineNumber_Endnote_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_BillId_SequenceNumber_LineNumber_Endnote_OdsCustomerId_OdsPostingGroupAuditId 
ON src.SupplementBill_Pharm_ApportionmentEndnote (BillId,SequenceNumber,LineNumber,Endnote, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.SupplementBill_Pharm_ApportionmentEndnote')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.SupplementBill_Pharm_ApportionmentEndnote(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (BillId,SequenceNumber,LineNumber,Endnote);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.SupplementBill_Pharm_ApportionmentEndnote')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.SupplementBill_Pharm_ApportionmentEndnote(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,BillId,SequenceNumber,LineNumber,Endnote);
GO

