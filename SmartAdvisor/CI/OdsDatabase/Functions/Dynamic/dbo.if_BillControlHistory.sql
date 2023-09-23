IF OBJECT_ID('dbo.if_BillControlHistory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillControlHistory;
GO

CREATE FUNCTION dbo.if_BillControlHistory(
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
	t.BillControlHistorySeq,
	t.ClientCode,
	t.BillSeq,
	t.BillControlSeq,
	t.CreateDate,
	t.Control,
	t.ExternalID,
	t.EDIBatchLogSeq,
	t.Deleted,
	t.ModUserID,
	t.ExternalID2,
	t.Message
FROM src.BillControlHistory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillControlHistorySeq,
		ClientCode,
		BillSeq,
		BillControlSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillControlHistory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillControlHistorySeq,
		ClientCode,
		BillSeq,
		BillControlSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillControlHistorySeq = s.BillControlHistorySeq
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.BillControlSeq = s.BillControlSeq
WHERE t.DmlOperation <> 'D';

GO


