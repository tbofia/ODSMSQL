IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.IcdDiagnosisCodeDictionary')
	AND NAME = 'IX_DiagnosisCode_IcdVersion_StartDate_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_DiagnosisCode_IcdVersion_StartDate_OdsCustomerId_OdsPostingGroupAuditId 
ON src.IcdDiagnosisCodeDictionary (DiagnosisCode,IcdVersion,StartDate, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.IcdDiagnosisCodeDictionary')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.IcdDiagnosisCodeDictionary(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (DiagnosisCode,IcdVersion,StartDate);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.IcdDiagnosisCodeDictionary')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.IcdDiagnosisCodeDictionary(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,DiagnosisCode,IcdVersion,StartDate);
GO

