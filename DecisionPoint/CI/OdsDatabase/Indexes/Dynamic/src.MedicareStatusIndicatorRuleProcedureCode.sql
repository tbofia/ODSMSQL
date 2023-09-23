IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.MedicareStatusIndicatorRuleProcedureCode')
	AND NAME = 'IX_MedicareStatusIndicatorRuleId_ProcedureCode_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_MedicareStatusIndicatorRuleId_ProcedureCode_OdsCustomerId_OdsPostingGroupAuditId 
ON src.MedicareStatusIndicatorRuleProcedureCode (MedicareStatusIndicatorRuleId,ProcedureCode, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.MedicareStatusIndicatorRuleProcedureCode')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.MedicareStatusIndicatorRuleProcedureCode(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (MedicareStatusIndicatorRuleId,ProcedureCode);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.MedicareStatusIndicatorRuleProcedureCode')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.MedicareStatusIndicatorRuleProcedureCode(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,MedicareStatusIndicatorRuleId,ProcedureCode);
GO

