IF OBJECT_ID('dbo.if_LineReduction', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_LineReduction;
GO

CREATE FUNCTION dbo.if_LineReduction(
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
	t.LineSeq,
	t.ReductionCode,
	t.ReductionAmount,
	t.OverrideAmount,
	t.ModUserID
FROM src.LineReduction t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		BillSeq,
		LineSeq,
		ReductionCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.LineReduction
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		BillSeq,
		LineSeq,
		ReductionCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.LineSeq = s.LineSeq
	AND t.ReductionCode = s.ReductionCode
WHERE t.DmlOperation <> 'D';

GO


