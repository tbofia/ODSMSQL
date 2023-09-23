IF OBJECT_ID('dbo.if_prf_CTGPenaltyHdr', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_prf_CTGPenaltyHdr;
GO

CREATE FUNCTION dbo.if_prf_CTGPenaltyHdr(
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
	t.CTGPenHdrID,
	t.ProfileId,
	t.PenaltyType,
	t.PayNegRate,
	t.PayPPORate,
	t.DatesBasedOn,
	t.ApplyPenaltyToPharmacy,
	t.ApplyPenaltyCondition
FROM src.prf_CTGPenaltyHdr t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CTGPenHdrID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_CTGPenaltyHdr
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CTGPenHdrID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CTGPenHdrID = s.CTGPenHdrID
WHERE t.DmlOperation <> 'D';

GO


