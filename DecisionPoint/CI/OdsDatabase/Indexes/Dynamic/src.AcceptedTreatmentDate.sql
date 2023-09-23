IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.AcceptedTreatmentDate')
	AND NAME = 'IX_AcceptedTreatmentDateId_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_AcceptedTreatmentDateId_OdsCustomerId_OdsPostingGroupAuditId 
ON src.AcceptedTreatmentDate (AcceptedTreatmentDateId, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.AcceptedTreatmentDate')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.AcceptedTreatmentDate(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (AcceptedTreatmentDateId);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.AcceptedTreatmentDate')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.AcceptedTreatmentDate(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,AcceptedTreatmentDateId);
GO

