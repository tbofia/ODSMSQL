IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.MedicareStatusIndicatorRuleProviderSpecialty')
	AND NAME = 'IX_MedicareStatusIndicatorRuleId_ProviderSpecialty_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_MedicareStatusIndicatorRuleId_ProviderSpecialty_OdsCustomerId_OdsPostingGroupAuditId 
ON src.MedicareStatusIndicatorRuleProviderSpecialty (MedicareStatusIndicatorRuleId,ProviderSpecialty, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.MedicareStatusIndicatorRuleProviderSpecialty')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.MedicareStatusIndicatorRuleProviderSpecialty(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (MedicareStatusIndicatorRuleId,ProviderSpecialty);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.MedicareStatusIndicatorRuleProviderSpecialty')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.MedicareStatusIndicatorRuleProviderSpecialty(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,MedicareStatusIndicatorRuleId,ProviderSpecialty);
GO

