IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.MedicareStatusIndicatorRule')
	AND NAME = 'IX_MedicareStatusIndicatorRuleId_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_MedicareStatusIndicatorRuleId_OdsCustomerId_OdsPostingGroupAuditId 
ON src.MedicareStatusIndicatorRule (MedicareStatusIndicatorRuleId, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.MedicareStatusIndicatorRule')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.MedicareStatusIndicatorRule(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (MedicareStatusIndicatorRuleId);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.MedicareStatusIndicatorRule')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.MedicareStatusIndicatorRule(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,MedicareStatusIndicatorRuleId);
GO

