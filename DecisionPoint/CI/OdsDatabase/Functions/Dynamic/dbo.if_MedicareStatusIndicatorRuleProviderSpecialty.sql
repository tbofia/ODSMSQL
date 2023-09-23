IF OBJECT_ID('dbo.if_MedicareStatusIndicatorRuleProviderSpecialty', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_MedicareStatusIndicatorRuleProviderSpecialty;
GO

CREATE FUNCTION dbo.if_MedicareStatusIndicatorRuleProviderSpecialty(
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
	t.MedicareStatusIndicatorRuleId,
	t.ProviderSpecialty
FROM src.MedicareStatusIndicatorRuleProviderSpecialty t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		ProviderSpecialty,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.MedicareStatusIndicatorRuleProviderSpecialty
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		ProviderSpecialty) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.MedicareStatusIndicatorRuleId = s.MedicareStatusIndicatorRuleId
	AND t.ProviderSpecialty = s.ProviderSpecialty
WHERE t.DmlOperation <> 'D';

GO


