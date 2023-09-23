IF OBJECT_ID('dbo.if_BILLS_Endnotes', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BILLS_Endnotes;
GO

CREATE FUNCTION dbo.if_BILLS_Endnotes(
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
	t.BillIDNo,
	t.LINE_NO,
	t.EndNote,
	t.Referral,
	t.PercentDiscount,
	t.ActionId,
	t.EndnoteTypeId
FROM src.BILLS_Endnotes t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIDNo,
		LINE_NO,
		EndNote,
		EndnoteTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BILLS_Endnotes
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIDNo,
		LINE_NO,
		EndNote,
		EndnoteTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIDNo = s.BillIDNo
	AND t.LINE_NO = s.LINE_NO
	AND t.EndNote = s.EndNote
	AND t.EndnoteTypeId = s.EndnoteTypeId
WHERE t.DmlOperation <> 'D';

GO


