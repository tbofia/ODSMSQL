IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.EvaluationSummaryTemplateVersion')
	AND NAME = 'IX_EvaluationSummaryTemplateVersionId_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_EvaluationSummaryTemplateVersionId_OdsCustomerId_OdsPostingGroupAuditId 
ON src.EvaluationSummaryTemplateVersion (EvaluationSummaryTemplateVersionId, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.EvaluationSummaryTemplateVersion')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.EvaluationSummaryTemplateVersion(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (EvaluationSummaryTemplateVersionId);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.EvaluationSummaryTemplateVersion')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.EvaluationSummaryTemplateVersion(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,EvaluationSummaryTemplateVersionId);
GO

