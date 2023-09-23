IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.MedicalCodeCutOffs')
	AND NAME = 'IX_CodeTypeID_Code_FormType_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_CodeTypeID_Code_FormType_OdsCustomerId_OdsPostingGroupAuditId 
ON src.MedicalCodeCutOffs (CodeTypeID,Code,FormType, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.MedicalCodeCutOffs')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.MedicalCodeCutOffs(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (CodeTypeID,Code,FormType);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.MedicalCodeCutOffs')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.MedicalCodeCutOffs(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,CodeTypeID,Code,FormType);
GO

