IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.CMT_ICD9')
	AND NAME = 'IX_BillIDNo_SeqNo_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_BillIDNo_SeqNo_OdsCustomerId_OdsPostingGroupAuditId 
ON src.CMT_ICD9 (BillIDNo,SeqNo, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.CMT_ICD9')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.CMT_ICD9(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (BillIDNo,SeqNo);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.CMT_ICD9')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.CMT_ICD9(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,BillIDNo,SeqNo);
GO

