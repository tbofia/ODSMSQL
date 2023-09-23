IF OBJECT_ID('dbo.if_Provider', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Provider;
GO

CREATE FUNCTION dbo.if_Provider(
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
	t.ProviderSubSet,
	t.ProviderSeq,
	t.TIN,
	t.TINSuffix,
	t.ExternalID,
	t.Name,
	t.GroupCode,
	t.LicenseNum,
	t.MedicareNum,
	t.PracticeAddressSeq,
	t.BillingAddressSeq,
	t.HospitalSeq,
	t.ProvType,
	t.Specialty1,
	t.Specialty2,
	t.CreateUserID,
	t.CreateDate,
	t.ModUserID,
	t.ModDate,
	t.Status,
	t.ExternalStatus,
	t.ExportDate,
	t.SsnTinIndicator,
	t.PmtDays,
	t.AuthBeginDate,
	t.AuthEndDate,
	t.TaxAddressSeq,
	t.CtrlNum1099,
	t.SurchargeCode,
	t.WorkCompNum,
	t.WorkCompState,
	t.NCPDPID,
	t.EntityType,
	t.LastName,
	t.FirstName,
	t.MiddleName,
	t.Suffix,
	t.NPI,
	t.FacilityNPI,
	t.VerificationGroupID
FROM src.Provider t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProviderSubSet,
		ProviderSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Provider
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProviderSubSet,
		ProviderSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProviderSubSet = s.ProviderSubSet
	AND t.ProviderSeq = s.ProviderSeq
WHERE t.DmlOperation <> 'D';

GO


