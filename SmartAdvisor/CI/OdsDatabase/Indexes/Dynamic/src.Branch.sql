IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.Branch')
	AND NAME = 'IX_ClaimSysSubSet_BranchSeq_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_ClaimSysSubSet_BranchSeq_OdsCustomerId_OdsPostingGroupAuditId 
ON src.Branch (ClaimSysSubSet,BranchSeq, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Branch')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.Branch(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (ClaimSysSubSet,BranchSeq);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Branch')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.Branch(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,ClaimSysSubSet,BranchSeq);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Branch')
	AND NAME = N'IX_OdsPostingGroupAuditId')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId
ON src.Branch(OdsPostingGroupAuditId)
INCLUDE (OdsCustomerId,OdsRowIsCurrent,OdsHashbytesValue,ClaimSysSubSet,BranchSeq);
GO


