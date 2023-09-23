IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.IcdDiagnosisCodeDictionaryBodyPart')
	AND NAME = 'IX_DiagnosisCode_IcdVersion_StartDate_NcciBodyPartId_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_DiagnosisCode_IcdVersion_StartDate_NcciBodyPartId_OdsCustomerId_OdsPostingGroupAuditId 
ON src.IcdDiagnosisCodeDictionaryBodyPart (DiagnosisCode,IcdVersion,StartDate,NcciBodyPartId, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.IcdDiagnosisCodeDictionaryBodyPart')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.IcdDiagnosisCodeDictionaryBodyPart(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (DiagnosisCode,IcdVersion,StartDate,NcciBodyPartId);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.IcdDiagnosisCodeDictionaryBodyPart')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.IcdDiagnosisCodeDictionaryBodyPart(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,DiagnosisCode,IcdVersion,StartDate,NcciBodyPartId);
GO

