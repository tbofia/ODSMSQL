IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.StateSettingsFlorida')
	AND NAME = 'IX_StateSettingsFloridaId_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_StateSettingsFloridaId_OdsCustomerId_OdsPostingGroupAuditId 
ON src.StateSettingsFlorida (StateSettingsFloridaId, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.StateSettingsFlorida')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.StateSettingsFlorida(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (StateSettingsFloridaId);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.StateSettingsFlorida')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.StateSettingsFlorida(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,StateSettingsFloridaId);
GO

