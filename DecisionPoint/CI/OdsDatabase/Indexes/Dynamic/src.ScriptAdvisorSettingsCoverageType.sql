IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.ScriptAdvisorSettingsCoverageType')
	AND NAME = 'IX_ScriptAdvisorSettingsId_CoverageType_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_ScriptAdvisorSettingsId_CoverageType_OdsCustomerId_OdsPostingGroupAuditId 
ON src.ScriptAdvisorSettingsCoverageType (ScriptAdvisorSettingsId,CoverageType, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.ScriptAdvisorSettingsCoverageType')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.ScriptAdvisorSettingsCoverageType(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (ScriptAdvisorSettingsId,CoverageType);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.ScriptAdvisorSettingsCoverageType')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.ScriptAdvisorSettingsCoverageType(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,ScriptAdvisorSettingsId,CoverageType);
GO

