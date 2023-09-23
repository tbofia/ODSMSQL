IF OBJECT_ID('dbo.if_StateSettingsFlorida', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_StateSettingsFlorida;
GO

CREATE FUNCTION dbo.if_StateSettingsFlorida(
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
	t.StateSettingsFloridaId,
	t.ClaimantInitialServiceOption,
	t.ClaimantInitialServiceDays
FROM src.StateSettingsFlorida t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StateSettingsFloridaId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsFlorida
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StateSettingsFloridaId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StateSettingsFloridaId = s.StateSettingsFloridaId
WHERE t.DmlOperation <> 'D';

GO


