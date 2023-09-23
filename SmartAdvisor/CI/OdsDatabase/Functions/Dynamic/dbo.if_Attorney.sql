IF OBJECT_ID('dbo.if_Attorney', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Attorney;
GO

CREATE FUNCTION dbo.if_Attorney(
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
	t.ClaimSysSubSet,
	t.AttorneySeq,
	t.TIN,
	t.TINSuffix,
	t.ExternalID,
	t.Name,
	t.GroupCode,
	t.LicenseNum,
	t.MedicareNum,
	t.PracticeAddressSeq,
	t.BillingAddressSeq,
	t.AttorneyType,
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
	t.WorkCompState
FROM src.Attorney t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimSysSubSet,
		AttorneySeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Attorney
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimSysSubSet,
		AttorneySeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimSysSubSet = s.ClaimSysSubSet
	AND t.AttorneySeq = s.AttorneySeq
WHERE t.DmlOperation <> 'D';

GO


