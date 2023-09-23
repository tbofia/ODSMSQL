IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.Esp_Ppo_Billing_Data_Self_Bill')
	AND NAME = 'IX_VPN_TRANSACTIONID_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_VPN_TRANSACTIONID_OdsCustomerId_OdsPostingGroupAuditId 
ON src.Esp_Ppo_Billing_Data_Self_Bill (VPN_TRANSACTIONID, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Esp_Ppo_Billing_Data_Self_Bill')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.Esp_Ppo_Billing_Data_Self_Bill(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (VPN_TRANSACTIONID);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Esp_Ppo_Billing_Data_Self_Bill')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.Esp_Ppo_Billing_Data_Self_Bill(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,VPN_TRANSACTIONID);
GO

