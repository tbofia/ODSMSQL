IF OBJECT_ID('aw.if_EventLogDetail', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_EventLogDetail;
GO

CREATE FUNCTION aw.if_EventLogDetail(
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
	t.EventLogDetailId,
	t.EventLogId,
	t.PropertyName,
	t.OldValue,
	t.NewValue
FROM src.EventLogDetail t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EventLogDetailId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EventLogDetail
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EventLogDetailId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EventLogDetailId = s.EventLogDetailId
WHERE t.DmlOperation <> 'D';

GO


