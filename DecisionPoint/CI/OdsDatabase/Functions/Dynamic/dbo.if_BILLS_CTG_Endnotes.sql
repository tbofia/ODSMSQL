IF OBJECT_ID('dbo.if_BILLS_CTG_Endnotes', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BILLS_CTG_Endnotes;
GO

CREATE FUNCTION dbo.if_BILLS_CTG_Endnotes(
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
	t.Line_No,
	t.Endnote,
	t.RuleType,
	t.RuleId,
	t.PreCertAction,
	t.PercentDiscount,
	t.ActionId
FROM src.BILLS_CTG_Endnotes t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		Line_No,
		Endnote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BILLS_CTG_Endnotes
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo,
		Line_No,
		Endnote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
	AND t.Line_No = s.Line_No
	AND t.Endnote = s.Endnote
WHERE t.DmlOperation <> 'D';

GO


