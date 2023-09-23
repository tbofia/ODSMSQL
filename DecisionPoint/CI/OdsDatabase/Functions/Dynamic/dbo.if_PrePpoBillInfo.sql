IF OBJECT_ID('dbo.if_PrePpoBillInfo', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_PrePpoBillInfo;
GO

CREATE FUNCTION dbo.if_PrePpoBillInfo(
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
	t.DateSentToPPO,
	t.ClaimNo,
	t.ClaimIDNo,
	t.CompanyID,
	t.OfficeIndex,
	t.CV_Code,
	t.DateLoss,
	t.Deductible,
	t.PaidCoPay,
	t.PaidDeductible,
	t.LossState,
	t.CmtIDNo,
	t.CmtCoPaymentMax,
	t.CmtCoPaymentPercentage,
	t.CmtDedType,
	t.CmtDeductible,
	t.CmtFLCopay,
	t.CmtPolicyLimit,
	t.CmtStateOfJurisdiction,
	t.PvdIDNo,
	t.PvdTIN,
	t.PvdSPC_List,
	t.PvdTitle,
	t.PvdFlags,
	t.DateSaved,
	t.DateRcv,
	t.InvoiceDate,
	t.NoLines,
	t.AmtCharged,
	t.AmtAllowed,
	t.Region,
	t.FeatureID,
	t.Flags,
	t.WhoCreate,
	t.WhoLast,
	t.CmtPaidDeductible,
	t.InsPaidLimit,
	t.StatusFlag,
	t.CmtPaidCoPay,
	t.Category,
	t.CatDesc,
	t.CreateDate,
	t.PvdZOS,
	t.AdmissionDate,
	t.DischargeDate,
	t.DischargeStatus,
	t.TypeOfBill,
	t.PaymentDecision,
	t.PPONumberSent,
	t.BillIDNo,
	t.LINE_NO,
	t.LINE_NO_DISP,
	t.OVER_RIDE,
	t.DT_SVC,
	t.PRC_CD,
	t.UNITS,
	t.TS_CD,
	t.CHARGED,
	t.ALLOWED,
	t.ANALYZED,
	t.REF_LINE_NO,
	t.SUBNET,
	t.FEE_SCHEDULE,
	t.POS_RevCode,
	t.CTGPenalty,
	t.PrePPOAllowed,
	t.PPODate,
	t.PPOCTGPenalty,
	t.UCRPerUnit,
	t.FSPerUnit,
	t.HCRA_Surcharge,
	t.NDC,
	t.PriceTypeCode,
	t.PharmacyLine,
	t.Endnotes,
	t.SentryEN,
	t.CTGEN,
	t.CTGRuleType,
	t.CTGRuleID,
	t.OverrideEN,
	t.UserId,
	t.DateOverriden,
	t.AmountBeforeOverride,
	t.AmountAfterOverride,
	t.CodesOverriden,
	t.NetworkID,
	t.BillSnapshot,
	t.PPOSavings,
	t.RevisedDate,
	t.ReconsideredDate,
	t.TierNumber,
	t.PPOBillInfoID,
	t.PrePPOBillInfoID,
	t.CtgCoPayPenalty,
	t.PpoCtgCoPayPenaltyPercentage,
	t.CtgVunPenalty,
	t.PpoCtgVunPenaltyPercentage
FROM src.PrePpoBillInfo t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PrePPOBillInfoID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PrePpoBillInfo
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PrePPOBillInfoID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PrePPOBillInfoID = s.PrePPOBillInfoID
WHERE t.DmlOperation <> 'D';

GO


