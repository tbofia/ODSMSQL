IF OBJECT_ID('dbo.if_SupplementPreCtgDeniedLinesEligibleToPenalty', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SupplementPreCtgDeniedLinesEligibleToPenalty;
GO

CREATE FUNCTION dbo.if_SupplementPreCtgDeniedLinesEligibleToPenalty(
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
	t.LineNumber,
	t.CtgPenaltyTypeId,
	t.SeqNo
FROM src.SupplementPreCtgDeniedLinesEligibleToPenalty t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		LineNumber,
		CtgPenaltyTypeId,
		SeqNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SupplementPreCtgDeniedLinesEligibleToPenalty
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo,
		LineNumber,
		CtgPenaltyTypeId,
		SeqNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
	AND t.LineNumber = s.LineNumber
	AND t.CtgPenaltyTypeId = s.CtgPenaltyTypeId
	AND t.SeqNo = s.SeqNo
WHERE t.DmlOperation <> 'D';

GO


