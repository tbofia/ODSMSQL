IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.ProviderNumberCriteriaTypeOfBill')
	AND NAME = 'IX_ProviderNumberCriteriaId_TypeOfBill_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_ProviderNumberCriteriaId_TypeOfBill_OdsCustomerId_OdsPostingGroupAuditId 
ON src.ProviderNumberCriteriaTypeOfBill (ProviderNumberCriteriaId,TypeOfBill, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.ProviderNumberCriteriaTypeOfBill')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.ProviderNumberCriteriaTypeOfBill(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (ProviderNumberCriteriaId,TypeOfBill);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.ProviderNumberCriteriaTypeOfBill')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.ProviderNumberCriteriaTypeOfBill(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,ProviderNumberCriteriaId,TypeOfBill);
GO

