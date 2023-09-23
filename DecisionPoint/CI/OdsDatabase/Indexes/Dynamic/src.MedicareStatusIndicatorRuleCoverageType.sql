IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.MedicareStatusIndicatorRuleCoverageType')
	AND NAME = 'IX_MedicareStatusIndicatorRuleId_ShortName_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_MedicareStatusIndicatorRuleId_ShortName_OdsCustomerId_OdsPostingGroupAuditId 
ON src.MedicareStatusIndicatorRuleCoverageType (MedicareStatusIndicatorRuleId,ShortName, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.MedicareStatusIndicatorRuleCoverageType')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.MedicareStatusIndicatorRuleCoverageType(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (MedicareStatusIndicatorRuleId,ShortName);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.MedicareStatusIndicatorRuleCoverageType')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.MedicareStatusIndicatorRuleCoverageType(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,MedicareStatusIndicatorRuleId,ShortName);
GO

