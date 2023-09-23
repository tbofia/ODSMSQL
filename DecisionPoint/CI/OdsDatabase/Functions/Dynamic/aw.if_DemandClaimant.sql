IF OBJECT_ID('aw.if_DemandClaimant', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_DemandClaimant;
GO

CREATE FUNCTION aw.if_DemandClaimant(
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
	t.DemandClaimantId,
	t.ExternalClaimantId,
	t.OrganizationId,
	t.HeightInInches,
	t.Weight,
	t.Occupation,
	t.BiReportStatus,
	t.HasDemandPackage,
	t.FactsOfLoss,
	t.PreExistingConditions,
	t.Archived
FROM src.DemandClaimant t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DemandClaimantId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.DemandClaimant
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DemandClaimantId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DemandClaimantId = s.DemandClaimantId
WHERE t.DmlOperation <> 'D';

GO


