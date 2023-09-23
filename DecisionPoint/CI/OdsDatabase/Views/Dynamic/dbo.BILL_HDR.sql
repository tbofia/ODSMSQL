IF OBJECT_ID('dbo.BILL_HDR', 'V') IS NOT NULL
    DROP VIEW dbo.BILL_HDR;
GO

CREATE VIEW dbo.BILL_HDR
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
	,CMT_HDR_IDNo
	,DateSaved
	,DateRcv
	,InvoiceNumber
	,InvoiceDate
	,FileNumber
	,Note
	,NoLines
	,AmtCharged
	,AmtAllowed
	,ReasonVersion
	,Region
	,PvdUpdateCounter
	,FeatureID
	,ClaimDateLoss
	,CV_Type
	,Flags
	,WhoCreate
	,WhoLast
	,AcceptAssignment
	,EmergencyService
	,CmtPaidDeductible
	,InsPaidLimit
	,StatusFlag
	,OfficeId
	,CmtPaidCoPay
	,AmbulanceMethod
	,StatusDate
	,Category
	,CatDesc
	,AssignedUser
	,CreateDate
	,PvdZOS
	,PPONumberSent
	,AdmissionDate
	,DischargeDate
	,DischargeStatus
	,TypeOfBill
	,SentryMessage
	,AmbulanceZipOfPickup
	,AmbulanceNumberOfPatients
	,WhoCreateID
	,WhoLastId
	,NYRequestDate
	,NYReceivedDate
	,ImgDocId
	,PaymentDecision
	,PvdCMSId
	,PvdNPINo
	,DischargeHour
	,PreCertChanged
	,DueDate
	,AttorneyIDNo
	,AssignedGroup
	,LastChangedOn
	,PrePPOAllowed
	,PPSCode
	,SOI
	,StatementStartDate
	,StatementEndDate
	,DeductibleOverride
	,AdmissionType
	,CoverageType
	,PricingProfileId
	,DesignatedPricingState
	,DateAnalyzed
	,SentToPpoSysId
	,PricingState
	,BillVpnEligible
	,ApportionmentPercentage
	,BillSourceId
	,OutOfStateProviderNumber
	,FloridaDeductibleRuleEligible
FROM src.BILL_HDR
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


