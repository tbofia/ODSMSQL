IF OBJECT_ID('dbo.ScriptAdvisorSettingsCoverageType', 'V') IS NOT NULL
    DROP VIEW dbo.ScriptAdvisorSettingsCoverageType;
GO

CREATE VIEW dbo.ScriptAdvisorSettingsCoverageType
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ScriptAdvisorSettingsId
	,CoverageType
FROM src.ScriptAdvisorSettingsCoverageType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


