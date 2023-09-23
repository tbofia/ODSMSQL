IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.Bills_OverrideEndNotes')
	AND NAME = 'IX_OverrideEndNoteID_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_OverrideEndNoteID_OdsCustomerId_OdsPostingGroupAuditId 
ON src.Bills_OverrideEndNotes (OverrideEndNoteID, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Bills_OverrideEndNotes')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.Bills_OverrideEndNotes(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (OverrideEndNoteID);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Bills_OverrideEndNotes')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.Bills_OverrideEndNotes(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,OverrideEndNoteID);
GO

