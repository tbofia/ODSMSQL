IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.ProviderNumberCriteriaRevenueCode')
	AND NAME = 'IX_ProviderNumberCriteriaId_RevenueCode_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_ProviderNumberCriteriaId_RevenueCode_OdsCustomerId_OdsPostingGroupAuditId 
ON src.ProviderNumberCriteriaRevenueCode (ProviderNumberCriteriaId,RevenueCode, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.ProviderNumberCriteriaRevenueCode')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.ProviderNumberCriteriaRevenueCode(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (ProviderNumberCriteriaId,RevenueCode);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.ProviderNumberCriteriaRevenueCode')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.ProviderNumberCriteriaRevenueCode(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,ProviderNumberCriteriaId,RevenueCode);
GO

