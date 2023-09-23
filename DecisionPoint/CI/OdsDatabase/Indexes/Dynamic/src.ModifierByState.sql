IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.ModifierByState')
	AND NAME = 'IX_State_ProcedureServiceCategoryId_ModifierDictionaryId_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_State_ProcedureServiceCategoryId_ModifierDictionaryId_OdsCustomerId_OdsPostingGroupAuditId 
ON src.ModifierByState (State,ProcedureServiceCategoryId,ModifierDictionaryId, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.ModifierByState')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.ModifierByState(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (State,ProcedureServiceCategoryId,ModifierDictionaryId);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.ModifierByState')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.ModifierByState(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,State,ProcedureServiceCategoryId,ModifierDictionaryId);
GO

