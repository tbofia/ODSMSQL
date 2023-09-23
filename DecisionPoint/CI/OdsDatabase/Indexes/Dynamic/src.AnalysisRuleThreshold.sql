IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.AnalysisRuleThreshold')
	AND NAME = 'IX_AnalysisRuleThresholdId_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_AnalysisRuleThresholdId_OdsCustomerId_OdsPostingGroupAuditId 
ON src.AnalysisRuleThreshold (AnalysisRuleThresholdId, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.AnalysisRuleThreshold')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.AnalysisRuleThreshold(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (AnalysisRuleThresholdId);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.AnalysisRuleThreshold')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.AnalysisRuleThreshold(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,AnalysisRuleThresholdId);
GO

