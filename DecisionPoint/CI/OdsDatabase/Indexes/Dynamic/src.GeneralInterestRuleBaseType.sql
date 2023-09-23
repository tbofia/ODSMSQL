IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.GeneralInterestRuleBaseType')
	AND NAME = 'IX_GeneralInterestRuleBaseTypeId_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_GeneralInterestRuleBaseTypeId_OdsCustomerId_OdsPostingGroupAuditId 
ON src.GeneralInterestRuleBaseType (GeneralInterestRuleBaseTypeId, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.GeneralInterestRuleBaseType')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.GeneralInterestRuleBaseType(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (GeneralInterestRuleBaseTypeId);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.GeneralInterestRuleBaseType')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.GeneralInterestRuleBaseType(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,GeneralInterestRuleBaseTypeId);
GO

