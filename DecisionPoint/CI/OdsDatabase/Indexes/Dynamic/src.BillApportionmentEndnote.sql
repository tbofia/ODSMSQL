IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.BillApportionmentEndnote')
	AND NAME = 'IX_BillId_LineNumber_Endnote_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_BillId_LineNumber_Endnote_OdsCustomerId_OdsPostingGroupAuditId 
ON src.BillApportionmentEndnote (BillId,LineNumber,Endnote, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.BillApportionmentEndnote')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.BillApportionmentEndnote(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (BillId,LineNumber,Endnote);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.BillApportionmentEndnote')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.BillApportionmentEndnote(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,BillId,LineNumber,Endnote);
GO

