IF OBJECT_ID('dbo.if_BILLS', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BILLS;
GO

CREATE FUNCTION dbo.if_BILLS(
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
	t.REASON1,
	t.REASON2,
	t.REASON3,
	t.REASON4,
	t.REASON5,
	t.REASON6,
	t.REASON7,
	t.REASON8,
	t.REF_LINE_NO,
	t.SUBNET,
	t.OverrideReason,
	t.FEE_SCHEDULE,
	t.POS_RevCode,
	t.CTGPenalty,
	t.PrePPOAllowed,
	t.PPODate,
	t.PPOCTGPenalty,
	t.UCRPerUnit,
	t.FSPerUnit,
	t.HCRA_Surcharge,
	t.EligibleAmt,
	t.DPAllowed,
	t.EndDateOfService,
	t.AnalyzedCtgPenalty,
	t.AnalyzedCtgPpoPenalty,
	t.RepackagedNdc,
	t.OriginalNdc,
	t.UnitOfMeasureId,
	t.PackageTypeOriginalNdc,
	t.ServiceCode,
	t.PreApportionedAmount,
	t.DeductibleApplied,
	t.BillReviewResults,
	t.PreOverriddenDeductible,
	t.RemainingBalance,
	t.CtgCoPayPenalty,
	t.PpoCtgCoPayPenaltyPercentage,
	t.AnalyzedCtgCoPayPenalty,
	t.AnalyzedPpoCtgCoPayPenaltyPercentage,
	t.CtgVunPenalty,
	t.PpoCtgVunPenaltyPercentage,
	t.AnalyzedCtgVunPenalty,
	t.AnalyzedPpoCtgVunPenaltyPercentage,
	t.RenderingNpi
FROM src.BILLS t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIDNo,
		LINE_NO,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BILLS
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIDNo,
		LINE_NO) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIDNo = s.BillIDNo
	AND t.LINE_NO = s.LINE_NO
WHERE t.DmlOperation <> 'D';

GO


