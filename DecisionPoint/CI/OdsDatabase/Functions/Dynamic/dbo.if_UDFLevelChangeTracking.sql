IF OBJECT_ID('dbo.if_UDFLevelChangeTracking', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_UDFLevelChangeTracking;
GO

CREATE FUNCTION dbo.if_UDFLevelChangeTracking(
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
	t.UDFLevelChangeTrackingId,
	t.EntityType,
	t.EntityId,
	t.CorrelationId,
	t.UDFId,
	t.PreviousValue,
	t.UpdatedValue,
	t.UserId,
	t.ChangeDate
FROM src.UDFLevelChangeTracking t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		UDFLevelChangeTrackingId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDFLevelChangeTracking
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		UDFLevelChangeTrackingId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.UDFLevelChangeTrackingId = s.UDFLevelChangeTrackingId
WHERE t.DmlOperation <> 'D';

GO


