IF OBJECT_ID('dbo.if_Bill_Payment_Adjustments', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Bill_Payment_Adjustments;
GO

CREATE FUNCTION dbo.if_Bill_Payment_Adjustments(
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
	t.Bill_Payment_Adjustment_ID,
	t.BillIDNo,
	t.SeqNo,
	t.InterestFlags,
	t.DateInterestStarts,
	t.DateInterestEnds,
	t.InterestAdditionalInfoReceived,
	t.Interest,
	t.Comments
FROM src.Bill_Payment_Adjustments t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Bill_Payment_Adjustment_ID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bill_Payment_Adjustments
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Bill_Payment_Adjustment_ID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Bill_Payment_Adjustment_ID = s.Bill_Payment_Adjustment_ID
WHERE t.DmlOperation <> 'D';

GO


