IF OBJECT_ID('aw.if_ManualProviderSpecialty', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_ManualProviderSpecialty;
GO

CREATE FUNCTION aw.if_ManualProviderSpecialty(
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
	t.Specialty
FROM src.ManualProviderSpecialty t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ManualProviderId,
		Specialty,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ManualProviderSpecialty
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ManualProviderId,
		Specialty) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ManualProviderId = s.ManualProviderId
	AND t.Specialty = s.Specialty
WHERE t.DmlOperation <> 'D';

GO


