IF OBJECT_ID('dbo.if_BILL_HDR', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BILL_HDR;
GO

CREATE FUNCTION dbo.if_BILL_HDR(
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
	t.BillIDNo,
	t.CMT_HDR_IDNo,
	t.DateSaved,
	t.DateRcv,
	t.InvoiceNumber,
	t.InvoiceDate,
	t.FileNumber,
	t.Note,
	t.NoLines,
	t.AmtCharged,
	t.AmtAllowed,
	t.ReasonVersion,
	t.Region,
	t.PvdUpdateCounter,
	t.FeatureID,
	t.ClaimDateLoss,
	t.CV_Type,
	t.Flags,
	t.WhoCreate,
	t.WhoLast,
	t.AcceptAssignment,
	t.EmergencyService,
	t.CmtPaidDeductible,
	t.InsPaidLimit,
	t.StatusFlag,
	t.OfficeId,
	t.CmtPaidCoPay,
	t.AmbulanceMethod,
	t.StatusDate,
	t.Category,
	t.CatDesc,
	t.AssignedUser,
	t.CreateDate,
	t.PvdZOS,
	t.PPONumberSent,
	t.AdmissionDate,
	t.DischargeDate,
	t.DischargeStatus,
	t.TypeOfBill,
	t.SentryMessage,
	t.AmbulanceZipOfPickup,
	t.AmbulanceNumberOfPatients,
	t.WhoCreateID,
	t.WhoLastId,
	t.NYRequestDate,
	t.NYReceivedDate,
	t.ImgDocId,
	t.PaymentDecision,
	t.PvdCMSId,
	t.PvdNPINo,
	t.DischargeHour,
	t.PreCertChanged,
	t.DueDate,
	t.AttorneyIDNo,
	t.AssignedGroup,
	t.LastChangedOn,
	t.PrePPOAllowed,
	t.PPSCode,
	t.SOI,
	t.StatementStartDate,
	t.StatementEndDate,
	t.DeductibleOverride,
	t.AdmissionType,
	t.CoverageType,
	t.PricingProfileId,
	t.DesignatedPricingState,
	t.DateAnalyzed,
	t.SentToPpoSysId,
	t.PricingState,
	t.BillVpnEligible,
	t.ApportionmentPercentage,
	t.BillSourceId,
	t.OutOfStateProviderNumber,
	t.FloridaDeductibleRuleEligible
FROM src.BILL_HDR t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIDNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BILL_HDR
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIDNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIDNo = s.BillIDNo
WHERE t.DmlOperation <> 'D';

GO


