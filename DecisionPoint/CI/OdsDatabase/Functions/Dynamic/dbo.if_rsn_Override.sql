IF OBJECT_ID('dbo.if_Rsn_Override', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Rsn_Override;
GO

CREATE FUNCTION dbo.if_Rsn_Override(
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
	t.ReasonNumber,
	t.ShortDesc,
	t.LongDesc,
	t.CategoryIdNo,
	t.ClientSpec,
	t.COAIndex,
	t.NJPenaltyPct,
	t.NetworkID,
	t.SpecialProcessing
FROM src.Rsn_Override t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Rsn_Override
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
WHERE t.DmlOperation <> 'D';

GO


