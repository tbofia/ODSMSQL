IF OBJECT_ID('aw.if_EventLog', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_EventLog;
GO

CREATE FUNCTION aw.if_EventLog(
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
	t.EventLogId,
	t.ObjectName,
	t.ObjectId,
	t.UserName,
	t.LogDate,
	t.ActionName,
	t.OrganizationId
FROM src.EventLog t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EventLogId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EventLog
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EventLogId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EventLogId = s.EventLogId
WHERE t.DmlOperation <> 'D';

GO


