IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.ServiceCodeGroup')
	AND NAME = 'IX_SiteCode_GroupType_Family_Revision_GroupCode_CodeOrder_ServiceCode_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_SiteCode_GroupType_Family_Revision_GroupCode_CodeOrder_ServiceCode_OdsCustomerId_OdsPostingGroupAuditId 
ON src.ServiceCodeGroup (SiteCode,GroupType,Family,Revision,GroupCode,CodeOrder,ServiceCode, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.ServiceCodeGroup')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.ServiceCodeGroup(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (SiteCode,GroupType,Family,Revision,GroupCode,CodeOrder,ServiceCode);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.ServiceCodeGroup')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.ServiceCodeGroup(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,SiteCode,GroupType,Family,Revision,GroupCode,CodeOrder,ServiceCode);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.ServiceCodeGroup')
	AND NAME = N'IX_OdsPostingGroupAuditId')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId
ON src.ServiceCodeGroup(OdsPostingGroupAuditId)
INCLUDE (OdsCustomerId,OdsRowIsCurrent,OdsHashbytesValue,SiteCode,GroupType,Family,Revision,GroupCode,CodeOrder,ServiceCode);
GO


