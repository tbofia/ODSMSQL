IF OBJECT_ID('dbo.BILLS', 'V') IS NOT NULL
    DROP VIEW dbo.BILLS;
GO

CREATE VIEW dbo.BILLS
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillIDNo
	,LINE_NO
	,LINE_NO_DISP
	,OVER_RIDE
	,DT_SVC
	,PRC_CD
	,UNITS
	,TS_CD
	,CHARGED
	,ALLOWED
	,ANALYZED
	,REASON1
	,REASON2
	,REASON3
	,REASON4
	,REASON5
	,REASON6
	,REASON7
	,REASON8
	,REF_LINE_NO
	,SUBNET
	,OverrideReason
	,FEE_SCHEDULE
	,POS_RevCode
	,CTGPenalty
	,PrePPOAllowed
	,PPODate
	,PPOCTGPenalty
	,UCRPerUnit
	,FSPerUnit
	,HCRA_Surcharge
	,EligibleAmt
	,DPAllowed
	,EndDateOfService
	,AnalyzedCtgPenalty
	,AnalyzedCtgPpoPenalty
	,RepackagedNdc
	,OriginalNdc
	,UnitOfMeasureId
	,PackageTypeOriginalNdc
	,ServiceCode
	,PreApportionedAmount
	,DeductibleApplied
	,BillReviewResults
	,PreOverriddenDeductible
	,RemainingBalance
	,CtgCoPayPenalty
	,PpoCtgCoPayPenaltyPercentage
	,AnalyzedCtgCoPayPenalty
	,AnalyzedPpoCtgCoPayPenaltyPercentage
	,CtgVunPenalty
	,PpoCtgVunPenaltyPercentage
	,AnalyzedCtgVunPenalty
	,AnalyzedPpoCtgVunPenaltyPercentage
	,RenderingNpi
FROM src.BILLS
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


