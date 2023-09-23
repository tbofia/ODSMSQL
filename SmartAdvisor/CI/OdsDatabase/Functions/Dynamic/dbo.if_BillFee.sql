IF OBJECT_ID('dbo.if_BillFee', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillFee;
GO

CREATE FUNCTION dbo.if_BillFee(
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
	t.FeeType,
	t.TransactionType,
	t.FeeCtrlSource,
	t.FeeControlSeq,
	t.FeeAmount,
	t.InvoiceSeq,
	t.InvoiceSubSeq,
	t.PPONetworkID,
	t.ReductionCode,
	t.FeeOverride,
	t.OverrideVerified,
	t.ExclusiveFee,
	t.FeeSourceID,
	t.HandlingFee
FROM src.BillFee t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		BillSeq,
		FeeType,
		TransactionType,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillFee
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		BillSeq,
		FeeType,
		TransactionType) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.FeeType = s.FeeType
	AND t.TransactionType = s.TransactionType
WHERE t.DmlOperation <> 'D';

GO


