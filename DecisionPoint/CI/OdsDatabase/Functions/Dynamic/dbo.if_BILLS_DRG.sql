IF OBJECT_ID('dbo.if_BILLS_DRG', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BILLS_DRG;
GO

CREATE FUNCTION dbo.if_BILLS_DRG(
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
	t.BillIdNo,
	t.PricerPassThru,
	t.PricerCapital_Outlier_Amt,
	t.PricerCapital_OldHarm_Amt,
	t.PricerCapital_IME_Amt,
	t.PricerCapital_HSP_Amt,
	t.PricerCapital_FSP_Amt,
	t.PricerCapital_Exceptions_Amt,
	t.PricerCapital_DSH_Amt,
	t.PricerCapitalPayment,
	t.PricerDSH,
	t.PricerIME,
	t.PricerCostOutlier,
	t.PricerHSP,
	t.PricerFSP,
	t.PricerTotalPayment,
	t.PricerReturnMsg,
	t.ReturnDRG,
	t.ReturnDRGDesc,
	t.ReturnMDC,
	t.ReturnMDCDesc,
	t.ReturnDRGWt,
	t.ReturnDRGALOS,
	t.ReturnADX,
	t.ReturnSDX,
	t.ReturnMPR,
	t.ReturnPR2,
	t.ReturnPR3,
	t.ReturnNOR,
	t.ReturnNO2,
	t.ReturnCOM,
	t.ReturnCMI,
	t.ReturnDCC,
	t.ReturnDX1,
	t.ReturnDX2,
	t.ReturnDX3,
	t.ReturnMCI,
	t.ReturnOR1,
	t.ReturnOR2,
	t.ReturnOR3,
	t.ReturnTRI,
	t.SOJ,
	t.OPCERT,
	t.BlendCaseInclMalp,
	t.CapitalCost,
	t.HospBadDebt,
	t.ExcessPhysMalp,
	t.SparcsPerCase,
	t.AltLevelOfCare,
	t.DRGWgt,
	t.TransferCapital,
	t.NYDrgType,
	t.LOS,
	t.TrimPoint,
	t.GroupBlendPercentage,
	t.AdjustmentFactor,
	t.HospLongStayGroupPrice,
	t.TotalDRGCharge,
	t.BlendCaseAdj,
	t.CapitalCostAdj,
	t.NonMedicareCaseMix,
	t.HighCostChargeConverter,
	t.DischargeCasePaymentRate,
	t.DirectMedicalEducation,
	t.CasePaymentCapitalPerDiem,
	t.HighCostOutlierThreshold,
	t.ISAF,
	t.ReturnSOI,
	t.CapitalCostPerDischarge,
	t.ReturnSOIDesc
FROM src.BILLS_DRG t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BILLS_DRG
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
WHERE t.DmlOperation <> 'D';

GO


