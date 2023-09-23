IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.BillRuleFire')
	AND NAME = 'IX_ClientCode_BillSeq_LineSeq_RuleID_ChildTargetSubset_ChildTargetSeq_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_ClientCode_BillSeq_LineSeq_RuleID_ChildTargetSubset_ChildTargetSeq_OdsCustomerId_OdsPostingGroupAuditId 
ON src.BillRuleFire (ClientCode,BillSeq,LineSeq,RuleID,ChildTargetSubset,ChildTargetSeq, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.BillRuleFire')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.BillRuleFire(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (ClientCode,BillSeq,LineSeq,RuleID,ChildTargetSubset,ChildTargetSeq);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.BillRuleFire')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.BillRuleFire(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,ClientCode,BillSeq,LineSeq,RuleID,ChildTargetSubset,ChildTargetSeq);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.BillRuleFire')
	AND NAME = N'IX_OdsPostingGroupAuditId')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId
ON src.BillRuleFire(OdsPostingGroupAuditId)
INCLUDE (OdsCustomerId,OdsRowIsCurrent,OdsHashbytesValue,ClientCode,BillSeq,LineSeq,RuleID,ChildTargetSubset,ChildTargetSeq);
GO


