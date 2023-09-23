IF OBJECT_ID('dbo.if_PPOContract', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_PPOContract;
GO

CREATE FUNCTION dbo.if_PPOContract(
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
	t.PPONetworkID,
	t.PPOContractID,
	t.SiteCode,
	t.TIN,
	t.AlternateTIN,
	t.StartDate,
	t.EndDate,
	t.OPLineItemDefaultDiscount,
	t.CompanyName,
	t.First,
	t.GroupCode,
	t.GroupName,
	t.OPDiscountBaseValue,
	t.OPOffFS,
	t.OPOffUCR,
	t.OPOffCharge,
	t.OPEffectiveDate,
	t.OPAdditionalDiscountOffLink,
	t.OPTerminationDate,
	t.OPUCRPercentile,
	t.OPCondition,
	t.IPDiscountBaseValue,
	t.IPOffFS,
	t.IPOffUCR,
	t.IPOffCharge,
	t.IPEffectiveDate,
	t.IPTerminationDate,
	t.IPCondition,
	t.IPStopCapAmount,
	t.IPStopCapRate,
	t.MinDisc,
	t.MaxDisc,
	t.MedicalPerdiem,
	t.SurgicalPerdiem,
	t.ICUPerdiem,
	t.PsychiatricPerdiem,
	t.MiscParm,
	t.SpcCode,
	t.PPOType,
	t.BillingAddress1,
	t.BillingAddress2,
	t.BillingCity,
	t.BillingState,
	t.BillingZip,
	t.PracticeAddress1,
	t.PracticeAddress2,
	t.PracticeCity,
	t.PracticeState,
	t.PracticeZip,
	t.PhoneNum,
	t.OutFile,
	t.InpatFile,
	t.URCoordinatorFlag,
	t.ExclusivePPOOrgFlag,
	t.StopLossTypeCode,
	t.BR_RNEDiscount,
	t.ModDate,
	t.ExportFlag,
	t.OPManualIndicator,
	t.OPStopCapAmount,
	t.OPStopCapRate,
	t.Specialty1,
	t.Specialty2,
	t.LessorOfThreshold,
	t.BilateralDiscount,
	t.SurgeryDiscount2,
	t.SurgeryDiscount3,
	t.SurgeryDiscount4,
	t.SurgeryDiscount5,
	t.Matrix,
	t.ProvType,
	t.AllInclusive,
	t.Region,
	t.PaymentAddressFlag,
	t.MedicalGroup,
	t.MedicalGroupCode,
	t.RateMode,
	t.PracticeCounty,
	t.FIPSCountyCode,
	t.PrimaryCareFlag,
	t.PPOContractIDOld,
	t.MultiSurg,
	t.BiLevel,
	t.DRGRate,
	t.DRGGreaterThanBC,
	t.DRGMinPercentBC,
	t.CarveOut,
	t.PPOtoFSSeq,
	t.LicenseNum,
	t.MedicareNum,
	t.NPI
FROM src.PPOContract t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PPONetworkID,
		PPOContractID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PPOContract
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PPONetworkID,
		PPOContractID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PPONetworkID = s.PPONetworkID
	AND t.PPOContractID = s.PPOContractID
WHERE t.DmlOperation <> 'D';

GO


