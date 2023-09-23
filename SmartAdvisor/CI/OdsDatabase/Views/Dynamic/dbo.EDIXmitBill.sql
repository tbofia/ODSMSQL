IF OBJECT_ID('dbo.EDIXmitBill', 'V') IS NOT NULL
    DROP VIEW dbo.EDIXmitBill;
GO

CREATE VIEW dbo.EDIXmitBill
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,EDIXmitBillSeq
	,EDIXmitSeq
	,EDIHistoryProviderSeq
	,EDIHistoryClaimSeq
	,EDIHistoryInsurerSeq
	,EDIControlSeq
	,ClientCode
	,BillSeq
	,Jurisdiction
	,TOB
	,UB92TOB
	,BillSeqOrgRev
	,TotalCharge
	,BillableLines
	,PaidDate
	,PaidAmount
	,DRG
	,PatientStatus
	,PostDate
	,DocCtrlID
	,DOSFirst
	,DOSLast
	,PPONetworkID
	,PPOContractID
	,Adjuster
	,CarrierSeqNew
	,ProvInvoice
	,ProvSpecialty1
	,ClientTOB
	,SubProductCode
	,DupClientCode
	,DupBillSeq
	,ConsultDate
	,AdmitDate
	,DischargeDate
	,SubmitDate
	,RcvdDate
	,RcvdBrDate
	,ReviewDate
	,DueDate
	,PmtAuth
	,ForcePay
	,ProvLicenseNum
	,CreateUserID
	,ModUserID
	,PatientAccount
	,RefProvName
	,ProvType
	,DOI
	,GeoState
	,ManualReductionMode
	,PPONetworkJurisdictionInd
	,PPONetworkJurisdictionInsurerSeq
	,WFQueueParameter1
	,CheckNum
	,ExternalID
	,EDITestIndicator
	,ICDVersion
FROM src.EDIXmitBill
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


