IF OBJECT_ID('dbo.if_CbreToDpEndnoteMapping', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CbreToDpEndnoteMapping;
GO

CREATE FUNCTION dbo.if_CbreToDpEndnoteMapping(
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
	t.EndnoteTypeId,
	t.CbreEndnote,
	t.PricingState,
	t.PricingMethodId
FROM src.CbreToDpEndnoteMapping t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Endnote,
		EndnoteTypeId,
		CbreEndnote,
		PricingState,
		PricingMethodId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CbreToDpEndnoteMapping
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Endnote,
		EndnoteTypeId,
		CbreEndnote,
		PricingState,
		PricingMethodId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Endnote = s.Endnote
	AND t.EndnoteTypeId = s.EndnoteTypeId
	AND t.CbreEndnote = s.CbreEndnote
	AND t.PricingState = s.PricingState
	AND t.PricingMethodId = s.PricingMethodId
WHERE t.DmlOperation <> 'D';

GO


