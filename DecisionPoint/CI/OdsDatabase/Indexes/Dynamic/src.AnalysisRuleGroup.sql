IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.AnalysisRuleGroup')
	AND NAME = 'IX_AnalysisRuleGroupId_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_AnalysisRuleGroupId_OdsCustomerId_OdsPostingGroupAuditId 
ON src.AnalysisRuleGroup (AnalysisRuleGroupId, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.AnalysisRuleGroup')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.AnalysisRuleGroup(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (AnalysisRuleGroupId);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.AnalysisRuleGroup')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.AnalysisRuleGroup(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,AnalysisRuleGroupId);
GO

