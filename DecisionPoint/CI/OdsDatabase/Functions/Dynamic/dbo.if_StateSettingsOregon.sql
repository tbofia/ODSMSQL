IF OBJECT_ID('dbo.if_StateSettingsOregon', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_StateSettingsOregon;
GO

CREATE FUNCTION dbo.if_StateSettingsOregon(
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
	t.StateSettingsOregonId,
	t.ApplyOregonFeeSchedule
FROM src.StateSettingsOregon t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StateSettingsOregonId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsOregon
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StateSettingsOregonId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StateSettingsOregonId = s.StateSettingsOregonId
WHERE t.DmlOperation <> 'D';

GO


