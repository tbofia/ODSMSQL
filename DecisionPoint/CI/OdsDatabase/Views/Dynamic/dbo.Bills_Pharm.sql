IF OBJECT_ID('dbo.Bills_Pharm', 'V') IS NOT NULL
    DROP VIEW dbo.Bills_Pharm;
GO

CREATE VIEW dbo.Bills_Pharm
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillIdNo
	,Line_No
	,LINE_NO_DISP
	,DateOfService
	,NDC
	,PriceTypeCode
	,Units
	,Charged
	,Allowed
	,EndNote
	,Override
	,Override_Rsn
	,Analyzed
	,CTGPenalty
	,PrePPOAllowed
	,PPODate
	,POS_RevCode
	,DPAllowed
	,HCRA_Surcharge
	,EndDateOfService
	,RepackagedNdc
	,OriginalNdc
	,UnitOfMeasureId
	,PackageTypeOriginalNdc
	,PpoCtgPenalty
	,ServiceCode
	,PreApportionedAmount
	,DeductibleApplied
	,BillReviewResults
	,PreOverriddenDeductible
	,RemainingBalance
	,CtgCoPayPenalty
	,PpoCtgCoPayPenaltyPercentage
	,CtgVunPenalty
	,PpoCtgVunPenaltyPercentage
	,RenderingNpi
FROM src.Bills_Pharm
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


