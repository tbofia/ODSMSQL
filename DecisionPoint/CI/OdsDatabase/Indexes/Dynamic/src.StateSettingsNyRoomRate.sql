IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.StateSettingsNyRoomRate')
	AND NAME = 'IX_StateSettingsNyRoomRateId_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_StateSettingsNyRoomRateId_OdsCustomerId_OdsPostingGroupAuditId 
ON src.StateSettingsNyRoomRate (StateSettingsNyRoomRateId, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.StateSettingsNyRoomRate')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.StateSettingsNyRoomRate(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (StateSettingsNyRoomRateId);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.StateSettingsNyRoomRate')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.StateSettingsNyRoomRate(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,StateSettingsNyRoomRateId);
GO

