IF OBJECT_ID('dbo.if_StateSettingsNewJerseyPolicyPreference', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_StateSettingsNewJerseyPolicyPreference;
GO

CREATE FUNCTION dbo.if_StateSettingsNewJerseyPolicyPreference(
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
	t.PolicyPreferenceId,
	t.ShareCoPayMaximum
FROM src.StateSettingsNewJerseyPolicyPreference t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PolicyPreferenceId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsNewJerseyPolicyPreference
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PolicyPreferenceId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PolicyPreferenceId = s.PolicyPreferenceId
WHERE t.DmlOperation <> 'D';

GO


