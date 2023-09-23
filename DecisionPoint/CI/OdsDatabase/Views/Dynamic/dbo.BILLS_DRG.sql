IF OBJECT_ID('dbo.BILLS_DRG', 'V') IS NOT NULL
    DROP VIEW dbo.BILLS_DRG;
GO

CREATE VIEW dbo.BILLS_DRG
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
	,PricerPassThru
	,PricerCapital_Outlier_Amt
	,PricerCapital_OldHarm_Amt
	,PricerCapital_IME_Amt
	,PricerCapital_HSP_Amt
	,PricerCapital_FSP_Amt
	,PricerCapital_Exceptions_Amt
	,PricerCapital_DSH_Amt
	,PricerCapitalPayment
	,PricerDSH
	,PricerIME
	,PricerCostOutlier
	,PricerHSP
	,PricerFSP
	,PricerTotalPayment
	,PricerReturnMsg
	,ReturnDRG
	,ReturnDRGDesc
	,ReturnMDC
	,ReturnMDCDesc
	,ReturnDRGWt
	,ReturnDRGALOS
	,ReturnADX
	,ReturnSDX
	,ReturnMPR
	,ReturnPR2
	,ReturnPR3
	,ReturnNOR
	,ReturnNO2
	,ReturnCOM
	,ReturnCMI
	,ReturnDCC
	,ReturnDX1
	,ReturnDX2
	,ReturnDX3
	,ReturnMCI
	,ReturnOR1
	,ReturnOR2
	,ReturnOR3
	,ReturnTRI
	,SOJ
	,OPCERT
	,BlendCaseInclMalp
	,CapitalCost
	,HospBadDebt
	,ExcessPhysMalp
	,SparcsPerCase
	,AltLevelOfCare
	,DRGWgt
	,TransferCapital
	,NYDrgType
	,LOS
	,TrimPoint
	,GroupBlendPercentage
	,AdjustmentFactor
	,HospLongStayGroupPrice
	,TotalDRGCharge
	,BlendCaseAdj
	,CapitalCostAdj
	,NonMedicareCaseMix
	,HighCostChargeConverter
	,DischargeCasePaymentRate
	,DirectMedicalEducation
	,CasePaymentCapitalPerDiem
	,HighCostOutlierThreshold
	,ISAF
	,ReturnSOI
	,CapitalCostPerDischarge
	,ReturnSOIDesc
FROM src.BILLS_DRG
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


