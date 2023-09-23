IF OBJECT_ID('dbo.if_ScriptAdvisorSettings', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ScriptAdvisorSettings;
GO

CREATE FUNCTION dbo.if_ScriptAdvisorSettings(
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
	t.IsPharmacyEligible,
	t.EnableSendCardToClaimant,
	t.EnableBillSource
FROM src.ScriptAdvisorSettings t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ScriptAdvisorSettingsId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ScriptAdvisorSettings
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ScriptAdvisorSettingsId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ScriptAdvisorSettingsId = s.ScriptAdvisorSettingsId
WHERE t.DmlOperation <> 'D';

GO


