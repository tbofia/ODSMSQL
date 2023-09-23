IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.Prf_CustomIcdAction')
	AND NAME = 'IX_CustomIcdActionId_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_CustomIcdActionId_OdsCustomerId_OdsPostingGroupAuditId 
ON src.Prf_CustomIcdAction (CustomIcdActionId, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Prf_CustomIcdAction')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.Prf_CustomIcdAction(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (CustomIcdActionId);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Prf_CustomIcdAction')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.Prf_CustomIcdAction(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,CustomIcdActionId);
GO

