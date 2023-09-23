IF OBJECT_ID('dbo.if_CustomBillStatuses', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CustomBillStatuses;
GO

CREATE FUNCTION dbo.if_CustomBillStatuses(
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
	t.StatusId,
	t.StatusName,
	t.StatusDescription
FROM src.CustomBillStatuses t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StatusId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CustomBillStatuses
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StatusId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StatusId = s.StatusId
WHERE t.DmlOperation <> 'D';

GO


