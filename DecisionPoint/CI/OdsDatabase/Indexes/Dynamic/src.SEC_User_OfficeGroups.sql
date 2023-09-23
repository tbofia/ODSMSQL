IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.SEC_User_OfficeGroups')
	AND NAME = 'IX_SECUserOfficeGroupId_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_SECUserOfficeGroupId_OdsCustomerId_OdsPostingGroupAuditId 
ON src.SEC_User_OfficeGroups (SECUserOfficeGroupId, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.SEC_User_OfficeGroups')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.SEC_User_OfficeGroups(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (SECUserOfficeGroupId);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.SEC_User_OfficeGroups')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.SEC_User_OfficeGroups(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,SECUserOfficeGroupId);
GO

