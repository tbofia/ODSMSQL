IF OBJECT_ID('dbo.if_Bills_Pharm', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Bills_Pharm;
GO

CREATE FUNCTION dbo.if_Bills_Pharm(
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
	t.Line_No,
	t.LINE_NO_DISP,
	t.DateOfService,
	t.NDC,
	t.PriceTypeCode,
	t.Units,
	t.Charged,
	t.Allowed,
	t.EndNote,
	t.Override,
	t.Override_Rsn,
	t.Analyzed,
	t.CTGPenalty,
	t.PrePPOAllowed,
	t.PPODate,
	t.POS_RevCode,
	t.DPAllowed,
	t.HCRA_Surcharge,
	t.EndDateOfService,
	t.RepackagedNdc,
	t.OriginalNdc,
	t.UnitOfMeasureId,
	t.PackageTypeOriginalNdc,
	t.PpoCtgPenalty,
	t.ServiceCode,
	t.PreApportionedAmount,
	t.DeductibleApplied,
	t.BillReviewResults,
	t.PreOverriddenDeductible,
	t.RemainingBalance,
	t.CtgCoPayPenalty,
	t.PpoCtgCoPayPenaltyPercentage,
	t.CtgVunPenalty,
	t.PpoCtgVunPenaltyPercentage,
	t.RenderingNpi
FROM src.Bills_Pharm t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		Line_No,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bills_Pharm
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo,
		Line_No) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
	AND t.Line_No = s.Line_No
WHERE t.DmlOperation <> 'D';

GO


