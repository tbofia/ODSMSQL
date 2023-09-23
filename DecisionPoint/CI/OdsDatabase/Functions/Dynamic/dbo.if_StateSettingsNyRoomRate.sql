IF OBJECT_ID('dbo.if_StateSettingsNyRoomRate', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_StateSettingsNyRoomRate;
GO

CREATE FUNCTION dbo.if_StateSettingsNyRoomRate(
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
	t.StateSettingsNyRoomRateId,
	t.StartDate,
	t.EndDate,
	t.RoomRate
FROM src.StateSettingsNyRoomRate t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StateSettingsNyRoomRateId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsNyRoomRate
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StateSettingsNyRoomRateId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StateSettingsNyRoomRateId = s.StateSettingsNyRoomRateId
WHERE t.DmlOperation <> 'D';

GO


