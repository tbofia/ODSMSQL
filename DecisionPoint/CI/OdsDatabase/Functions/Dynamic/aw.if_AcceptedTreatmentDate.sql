IF OBJECT_ID('aw.if_AcceptedTreatmentDate', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_AcceptedTreatmentDate;
GO

CREATE FUNCTION aw.if_AcceptedTreatmentDate(
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
	t.AcceptedTreatmentDateId,
	t.DemandClaimantId,
	t.TreatmentDate,
	t.Comments,
	t.TreatmentCategoryId,
	t.LastUpdatedBy,
	t.LastUpdatedDate
FROM src.AcceptedTreatmentDate t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		AcceptedTreatmentDateId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AcceptedTreatmentDate
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		AcceptedTreatmentDateId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.AcceptedTreatmentDateId = s.AcceptedTreatmentDateId
WHERE t.DmlOperation <> 'D';

GO


