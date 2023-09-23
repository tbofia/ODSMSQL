IF OBJECT_ID('dbo.if_DeductibleRuleExemptEndnote', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_DeductibleRuleExemptEndnote;
GO

CREATE FUNCTION dbo.if_DeductibleRuleExemptEndnote(
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
	t.Endnote,
	t.EndnoteTypeId
FROM src.DeductibleRuleExemptEndnote t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Endnote,
		EndnoteTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.DeductibleRuleExemptEndnote
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Endnote,
		EndnoteTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Endnote = s.Endnote
	AND t.EndnoteTypeId = s.EndnoteTypeId
WHERE t.DmlOperation <> 'D';

GO


