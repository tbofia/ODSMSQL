IF OBJECT_ID('dbo.if_CreditReason', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CreditReason;
GO

CREATE FUNCTION dbo.if_CreditReason(
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
	t.CreditReasonId,
	t.CreditReasonDesc,
	t.IsVisible
FROM src.CreditReason t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CreditReasonId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CreditReason
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CreditReasonId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CreditReasonId = s.CreditReasonId
WHERE t.DmlOperation <> 'D';

GO


