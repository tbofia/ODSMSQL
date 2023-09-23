IF OBJECT_ID('dbo.Line', 'V') IS NOT NULL
    DROP VIEW dbo.Line;
GO

CREATE VIEW dbo.Line
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClientCode
	,BillSeq
	,LineSeq
	,DupClientCode
	,DupBillSeq
	,DOS
	,ProcType
	,PPOOverride
	,ClientLineType
	,ProvType
	,URQtyAllow
	,URQtySvd
	,DOSTo
	,URAllow
	,URCaseSeq
	,RevenueCode
	,ProcBilled
	,URReviewSeq
	,URPriority
	,ProcCode
	,Units
	,AllowUnits
	,Charge
	,BRAllow
	,PPOAllow
	,PayOverride
	,ProcNew
	,AdjAllow
	,ReevalAmount
	,POS
	,DxRefList
	,TOS
	,ReevalTxtPtr
	,FSAmount
	,UCAmount
	,CoPay
	,Deductible
	,CostToChargeRatio
	,RXNumber
	,DaysSupply
	,DxRef
	,ExternalID
	,ItemCostInvoiced
	,ItemCostAdditional
	,Refill
	,ProvSecondaryID
	,Certification
	,ReevalTxtSrc
	,BasisOfCost
	,DMEFrequencyCode
	,ProvRenderingNPI
	,ProvSecondaryIDQualifier
	,PaidProcCode
	,PaidProcType
	,URStatus
	,URWorkflowStatus
	,OverrideAllowUnits
	,LineSeqOrgRev
	,ODGFlag
	,CompoundDrugIndicator
	,PriorAuthNum
	,ReevalParagraphJurisdiction
FROM src.Line
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


