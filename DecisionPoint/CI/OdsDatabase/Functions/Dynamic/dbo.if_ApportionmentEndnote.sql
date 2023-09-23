IF OBJECT_ID('dbo.if_ApportionmentEndnote', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ApportionmentEndnote;
GO

CREATE FUNCTION dbo.if_ApportionmentEndnote(
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
	t.ApportionmentEndnote,
	t.ShortDescription,
	t.LongDescription
FROM src.ApportionmentEndnote t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ApportionmentEndnote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ApportionmentEndnote
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ApportionmentEndnote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ApportionmentEndnote = s.ApportionmentEndnote
WHERE t.DmlOperation <> 'D';

GO


