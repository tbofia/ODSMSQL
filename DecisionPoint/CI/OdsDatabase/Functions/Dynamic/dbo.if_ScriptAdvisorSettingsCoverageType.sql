IF OBJECT_ID('dbo.if_ScriptAdvisorSettingsCoverageType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ScriptAdvisorSettingsCoverageType;
GO

CREATE FUNCTION dbo.if_ScriptAdvisorSettingsCoverageType(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.ScriptAdvisorSettingsId,
	t.CoverageType
FROM src.ScriptAdvisorSettingsCoverageType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ScriptAdvisorSettingsId,
		CoverageType,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ScriptAdvisorSettingsCoverageType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ScriptAdvisorSettingsId,
		CoverageType) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ScriptAdvisorSettingsId = s.ScriptAdvisorSettingsId
	AND t.CoverageType = s.CoverageType
WHERE t.DmlOperation <> 'D';

GO


