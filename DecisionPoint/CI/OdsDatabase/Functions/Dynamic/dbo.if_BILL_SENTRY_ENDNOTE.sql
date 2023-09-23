IF OBJECT_ID('dbo.if_Bill_Sentry_Endnote', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Bill_Sentry_Endnote;
GO

CREATE FUNCTION dbo.if_Bill_Sentry_Endnote(
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
	t.BillID,
	t.Line,
	t.RuleID,
	t.PercentDiscount,
	t.ActionId
FROM src.Bill_Sentry_Endnote t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillID,
		Line,
		RuleID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bill_Sentry_Endnote
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillID,
		Line,
		RuleID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillID = s.BillID
	AND t.Line = s.Line
	AND t.RuleID = s.RuleID
WHERE t.DmlOperation <> 'D';

GO


