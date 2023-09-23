IF OBJECT_ID('dbo.if_StateSettingsNewJersey', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_StateSettingsNewJersey;
GO

CREATE FUNCTION dbo.if_StateSettingsNewJersey(
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
	t.StateSettingsNewJerseyId,
	t.ByPassEmergencyServices
FROM src.StateSettingsNewJersey t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StateSettingsNewJerseyId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsNewJersey
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StateSettingsNewJerseyId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StateSettingsNewJerseyId = s.StateSettingsNewJerseyId
WHERE t.DmlOperation <> 'D';

GO


