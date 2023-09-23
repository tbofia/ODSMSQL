IF OBJECT_ID('dbo.if_StateSettingsHawaii', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_StateSettingsHawaii;
GO

CREATE FUNCTION dbo.if_StateSettingsHawaii(
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
	t.StateSettingsHawaiiId,
	t.PhysicalMedicineLimitOption
FROM src.StateSettingsHawaii t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StateSettingsHawaiiId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsHawaii
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StateSettingsHawaiiId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StateSettingsHawaiiId = s.StateSettingsHawaiiId
WHERE t.DmlOperation <> 'D';

GO


