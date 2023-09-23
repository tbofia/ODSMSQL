IF OBJECT_ID('dbo.if_EDIXmitBill', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_EDIXmitBill;
GO

CREATE FUNCTION dbo.if_EDIXmitBill(
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
	t.EDIXmitBillSeq,
	t.EDIXmitSeq,
	t.EDIHistoryProviderSeq,
	t.EDIHistoryClaimSeq,
	t.EDIHistoryInsurerSeq,
	t.EDIControlSeq,
	t.ClientCode,
	t.BillSeq,
	t.Jurisdiction,
	t.TOB,
	t.UB92TOB,
	t.BillSeqOrgRev,
	t.TotalCharge,
	t.BillableLines,
	t.PaidDate,
	t.PaidAmount,
	t.DRG,
	t.PatientStatus,
	t.PostDate,
	t.DocCtrlID,
	t.DOSFirst,
	t.DOSLast,
	t.PPONetworkID,
	t.PPOContractID,
	t.Adjuster,
	t.CarrierSeqNew,
	t.ProvInvoice,
	t.ProvSpecialty1,
	t.ClientTOB,
	t.SubProductCode,
	t.DupClientCode,
	t.DupBillSeq,
	t.ConsultDate,
	t.AdmitDate,
	t.DischargeDate,
	t.SubmitDate,
	t.RcvdDate,
	t.RcvdBrDate,
	t.ReviewDate,
	t.DueDate,
	t.PmtAuth,
	t.ForcePay,
	t.ProvLicenseNum,
	t.CreateUserID,
	t.ModUserID,
	t.PatientAccount,
	t.RefProvName,
	t.ProvType,
	t.DOI,
	t.GeoState,
	t.ManualReductionMode,
	t.PPONetworkJurisdictionInd,
	t.PPONetworkJurisdictionInsurerSeq,
	t.WFQueueParameter1,
	t.CheckNum,
	t.ExternalID,
	t.EDITestIndicator,
	t.ICDVersion
FROM src.EDIXmitBill t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EDIXmitBillSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EDIXmitBill
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EDIXmitBillSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EDIXmitBillSeq = s.EDIXmitBillSeq
WHERE t.DmlOperation <> 'D';

GO


