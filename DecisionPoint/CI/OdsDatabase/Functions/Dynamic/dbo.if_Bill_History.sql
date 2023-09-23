IF OBJECT_ID('dbo.if_Bill_History', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Bill_History;
GO

CREATE FUNCTION dbo.if_Bill_History(
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
	t.BillIdNo,
	t.SeqNo,
	t.DateCommitted,
	t.AmtCommitted,
	t.UserId,
	t.AmtCoPay,
	t.AmtDeductible,
	t.Flags,
	t.AmtSalesTax,
	t.AmtOtherTax,
	t.DeductibleOverride,
	t.PricingState,
	t.ApportionmentPercentage,
	t.FloridaDeductibleRuleEligible
FROM src.Bill_History t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		SeqNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bill_History
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo,
		SeqNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
	AND t.SeqNo = s.SeqNo
WHERE t.DmlOperation <> 'D';

GO


