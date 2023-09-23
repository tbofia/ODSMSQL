IF OBJECT_ID('dbo.if_ProviderSpecialty', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProviderSpecialty;
GO

CREATE FUNCTION dbo.if_ProviderSpecialty(
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
	t.ProviderId,
	t.SpecialtyCode
FROM src.ProviderSpecialty t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProviderId,
		SpecialtyCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderSpecialty
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProviderId,
		SpecialtyCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProviderId = s.ProviderId
	AND t.SpecialtyCode = s.SpecialtyCode
WHERE t.DmlOperation <> 'D';

GO


