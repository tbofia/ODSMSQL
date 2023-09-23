IF OBJECT_ID('aw.if_ClaimantManualProviderSummary', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_ClaimantManualProviderSummary;
GO

CREATE FUNCTION aw.if_ClaimantManualProviderSummary(
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
	t.ManualProviderId,
	t.DemandClaimantId,
	t.FirstDateOfService,
	t.LastDateOfService,
	t.Visits,
	t.ChargedAmount,
	t.EvaluatedAmount,
	t.MinimumEvaluatedAmount,
	t.MaximumEvaluatedAmount,
	t.Comments
FROM src.ClaimantManualProviderSummary t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ManualProviderId,
		DemandClaimantId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ClaimantManualProviderSummary
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ManualProviderId,
		DemandClaimantId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ManualProviderId = s.ManualProviderId
	AND t.DemandClaimantId = s.DemandClaimantId
WHERE t.DmlOperation <> 'D';

GO


