IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.VpnBillingCategory')
	AND NAME = 'IX_VpnBillingCategoryCode_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_VpnBillingCategoryCode_OdsCustomerId_OdsPostingGroupAuditId 
ON src.VpnBillingCategory (VpnBillingCategoryCode, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.VpnBillingCategory')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.VpnBillingCategory(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (VpnBillingCategoryCode);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.VpnBillingCategory')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.VpnBillingCategory(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,VpnBillingCategoryCode);
GO

