IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.Pend')
	AND NAME = 'IX_ClientCode_BillSeq_PendSeq_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_ClientCode_BillSeq_PendSeq_OdsCustomerId_OdsPostingGroupAuditId 
ON src.Pend (ClientCode,BillSeq,PendSeq, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Pend')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.Pend(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (ClientCode,BillSeq,PendSeq);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Pend')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.Pend(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,ClientCode,BillSeq,PendSeq);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Pend')
	AND NAME = N'IX_OdsPostingGroupAuditId')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId
ON src.Pend(OdsPostingGroupAuditId)
INCLUDE (OdsCustomerId,OdsRowIsCurrent,OdsHashbytesValue,ClientCode,BillSeq,PendSeq);
GO


