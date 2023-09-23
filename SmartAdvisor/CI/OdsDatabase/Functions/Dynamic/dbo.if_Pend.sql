IF OBJECT_ID('dbo.if_Pend', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Pend;
GO

CREATE FUNCTION dbo.if_Pend(
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
	t.ClientCode,
	t.BillSeq,
	t.PendSeq,
	t.PendDate,
	t.ReleaseFlag,
	t.PendToID,
	t.Priority,
	t.ReleaseDate,
	t.ReasonCode,
	t.PendByUserID,
	t.ReleaseByUserID,
	t.AutoPendFlag,
	t.RuleID,
	t.WFTaskSeq,
	t.ReleasedByExternalUserName
FROM src.Pend t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		BillSeq,
		PendSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Pend
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		BillSeq,
		PendSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.PendSeq = s.PendSeq
WHERE t.DmlOperation <> 'D';

GO


