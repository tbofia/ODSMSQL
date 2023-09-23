IF OBJECT_ID('dbo.if_prf_CTGPenalty', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_prf_CTGPenalty;
GO

CREATE FUNCTION dbo.if_prf_CTGPenalty(
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
	t.CTGPenID,
	t.ProfileId,
	t.ApplyPreCerts,
	t.NoPrecertLogged,
	t.MaxTotalPenalty,
	t.TurnTimeForAppeals,
	t.ApplyEndnoteForPercert,
	t.ApplyEndnoteForCarePath,
	t.ExemptPrecertPenalty,
	t.ApplyNetworkPenalty
FROM src.prf_CTGPenalty t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CTGPenID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_CTGPenalty
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CTGPenID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CTGPenID = s.CTGPenID
WHERE t.DmlOperation <> 'D';

GO


