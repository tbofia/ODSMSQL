IF OBJECT_ID('dbo.if_Jurisdiction', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Jurisdiction;
GO

CREATE FUNCTION dbo.if_Jurisdiction(
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
	t.JurisdictionID,
	t.Name,
	t.POSTableCode,
	t.TOSTableCode,
	t.TOBTableCode,
	t.ProvTypeTableCode,
	t.Hospital,
	t.ProvSpclTableCode,
	t.DaysToPay,
	t.DaysToPayQualify,
	t.OutPatientFS,
	t.ProcFileVer,
	t.AnestUnit,
	t.AnestRndUp,
	t.AnestFormat,
	t.StateMandateSSN,
	t.ICDEdition,
	t.ICD10ComplianceDate,
	t.eBillsDaysToPay,
	t.eBillsDaysToPayQualify,
	t.DisputeDaysToPay,
	t.DisputeDaysToPayQualify
FROM src.Jurisdiction t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		JurisdictionID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Jurisdiction
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		JurisdictionID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.JurisdictionID = s.JurisdictionID
WHERE t.DmlOperation <> 'D';

GO


