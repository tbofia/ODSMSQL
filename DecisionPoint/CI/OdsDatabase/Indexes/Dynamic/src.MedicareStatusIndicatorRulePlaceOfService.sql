IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.MedicareStatusIndicatorRulePlaceOfService')
	AND NAME = 'IX_MedicareStatusIndicatorRuleId_PlaceOfService_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_MedicareStatusIndicatorRuleId_PlaceOfService_OdsCustomerId_OdsPostingGroupAuditId 
ON src.MedicareStatusIndicatorRulePlaceOfService (MedicareStatusIndicatorRuleId,PlaceOfService, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.MedicareStatusIndicatorRulePlaceOfService')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.MedicareStatusIndicatorRulePlaceOfService(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (MedicareStatusIndicatorRuleId,PlaceOfService);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.MedicareStatusIndicatorRulePlaceOfService')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.MedicareStatusIndicatorRulePlaceOfService(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,MedicareStatusIndicatorRuleId,PlaceOfService);
GO

