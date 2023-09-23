IF OBJECT_ID('dbo.if_Bill_Pharm_ApportionmentEndnote', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Bill_Pharm_ApportionmentEndnote;
GO

CREATE FUNCTION dbo.if_Bill_Pharm_ApportionmentEndnote(
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
	t.LineNumber,
	t.Endnote
FROM src.Bill_Pharm_ApportionmentEndnote t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillId,
		LineNumber,
		Endnote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bill_Pharm_ApportionmentEndnote
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillId,
		LineNumber,
		Endnote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillId = s.BillId
	AND t.LineNumber = s.LineNumber
	AND t.Endnote = s.Endnote
WHERE t.DmlOperation <> 'D';

GO


