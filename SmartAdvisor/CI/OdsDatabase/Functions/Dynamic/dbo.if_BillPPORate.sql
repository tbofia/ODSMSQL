IF OBJECT_ID('dbo.if_BillPPORate', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillPPORate;
GO

CREATE FUNCTION dbo.if_BillPPORate(
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
	t.LinkName,
	t.RateType,
	t.Applied
FROM src.BillPPORate t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		BillSeq,
		LinkName,
		RateType,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillPPORate
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		BillSeq,
		LinkName,
		RateType) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.LinkName = s.LinkName
	AND t.RateType = s.RateType
WHERE t.DmlOperation <> 'D';

GO


