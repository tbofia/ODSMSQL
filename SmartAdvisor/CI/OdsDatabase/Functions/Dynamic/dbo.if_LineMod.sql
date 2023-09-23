IF OBJECT_ID('dbo.if_LineMod', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_LineMod;
GO

CREATE FUNCTION dbo.if_LineMod(
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
	t.ModSeq,
	t.UserEntered,
	t.ModSiteCode,
	t.Modifier,
	t.ReductionCode,
	t.ModSubset,
	t.ModUserID,
	t.ModDate,
	t.ReasonClientCode,
	t.ReasonBillSeq,
	t.ReasonLineSeq,
	t.ReasonType,
	t.ReasonValue
FROM src.LineMod t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		BillSeq,
		LineSeq,
		ModSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.LineMod
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		BillSeq,
		LineSeq,
		ModSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.LineSeq = s.LineSeq
	AND t.ModSeq = s.ModSeq
WHERE t.DmlOperation <> 'D';

GO


