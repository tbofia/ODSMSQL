IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.ClaimantProviderSummaryEvaluation')
	AND NAME = 'IX_ClaimantProviderSummaryEvaluationId_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_ClaimantProviderSummaryEvaluationId_OdsCustomerId_OdsPostingGroupAuditId 
ON src.ClaimantProviderSummaryEvaluation (ClaimantProviderSummaryEvaluationId, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.ClaimantProviderSummaryEvaluation')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.ClaimantProviderSummaryEvaluation(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (ClaimantProviderSummaryEvaluationId);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.ClaimantProviderSummaryEvaluation')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.ClaimantProviderSummaryEvaluation(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,ClaimantProviderSummaryEvaluationId);
GO

