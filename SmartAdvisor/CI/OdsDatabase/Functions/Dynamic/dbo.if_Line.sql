IF OBJECT_ID('dbo.if_Line', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Line;
GO

CREATE FUNCTION dbo.if_Line(
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
	t.ClientCode,
	t.BillSeq,
	t.LineSeq,
	t.DupClientCode,
	t.DupBillSeq,
	t.DOS,
	t.ProcType,
	t.PPOOverride,
	t.ClientLineType,
	t.ProvType,
	t.URQtyAllow,
	t.URQtySvd,
	t.DOSTo,
	t.URAllow,
	t.URCaseSeq,
	t.RevenueCode,
	t.ProcBilled,
	t.URReviewSeq,
	t.URPriority,
	t.ProcCode,
	t.Units,
	t.AllowUnits,
	t.Charge,
	t.BRAllow,
	t.PPOAllow,
	t.PayOverride,
	t.ProcNew,
	t.AdjAllow,
	t.ReevalAmount,
	t.POS,
	t.DxRefList,
	t.TOS,
	t.ReevalTxtPtr,
	t.FSAmount,
	t.UCAmount,
	t.CoPay,
	t.Deductible,
	t.CostToChargeRatio,
	t.RXNumber,
	t.DaysSupply,
	t.DxRef,
	t.ExternalID,
	t.ItemCostInvoiced,
	t.ItemCostAdditional,
	t.Refill,
	t.ProvSecondaryID,
	t.Certification,
	t.ReevalTxtSrc,
	t.BasisOfCost,
	t.DMEFrequencyCode,
	t.ProvRenderingNPI,
	t.ProvSecondaryIDQualifier,
	t.PaidProcCode,
	t.PaidProcType,
	t.URStatus,
	t.URWorkflowStatus,
	t.OverrideAllowUnits,
	t.LineSeqOrgRev,
	t.ODGFlag,
	t.CompoundDrugIndicator,
	t.PriorAuthNum,
	t.ReevalParagraphJurisdiction
FROM src.Line t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		BillSeq,
		LineSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Line
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		BillSeq,
		LineSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.LineSeq = s.LineSeq
WHERE t.DmlOperation <> 'D';

GO


