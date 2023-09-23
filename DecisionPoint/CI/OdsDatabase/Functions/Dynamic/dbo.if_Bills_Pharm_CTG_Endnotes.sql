IF OBJECT_ID('dbo.if_Bills_Pharm_CTG_Endnotes', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Bills_Pharm_CTG_Endnotes;
GO

CREATE FUNCTION dbo.if_Bills_Pharm_CTG_Endnotes(
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
	t.RuleType,
	t.RuleId,
	t.PreCertAction,
	t.PercentDiscount,
	t.ActionId
FROM src.Bills_Pharm_CTG_Endnotes t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIDNo,
		LINE_NO,
		EndNote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bills_Pharm_CTG_Endnotes
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIDNo,
		LINE_NO,
		EndNote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIDNo = s.BillIDNo
	AND t.LINE_NO = s.LINE_NO
	AND t.EndNote = s.EndNote
WHERE t.DmlOperation <> 'D';

GO


