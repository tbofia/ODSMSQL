IF OBJECT_ID('dbo.if_SupplementBillCustomEndnote', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SupplementBillCustomEndnote;
GO

CREATE FUNCTION dbo.if_SupplementBillCustomEndnote(
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
	t.BillId,
	t.SequenceNumber,
	t.LineNumber,
	t.Endnote
FROM src.SupplementBillCustomEndnote t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillId,
		SequenceNumber,
		LineNumber,
		Endnote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SupplementBillCustomEndnote
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillId,
		SequenceNumber,
		LineNumber,
		Endnote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillId = s.BillId
	AND t.SequenceNumber = s.SequenceNumber
	AND t.LineNumber = s.LineNumber
	AND t.Endnote = s.Endnote
WHERE t.DmlOperation <> 'D';

GO


