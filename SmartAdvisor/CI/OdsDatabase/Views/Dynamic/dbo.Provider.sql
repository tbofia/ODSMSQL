IF OBJECT_ID('dbo.Provider', 'V') IS NOT NULL
    DROP VIEW dbo.Provider;
GO

CREATE VIEW dbo.Provider
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProviderSubSet
	,ProviderSeq
	,TIN
	,TINSuffix
	,ExternalID
	,Name
	,GroupCode
	,LicenseNum
	,MedicareNum
	,PracticeAddressSeq
	,BillingAddressSeq
	,HospitalSeq
	,ProvType
	,Specialty1
	,Specialty2
	,CreateUserID
	,CreateDate
	,ModUserID
	,ModDate
	,Status
	,ExternalStatus
	,ExportDate
	,SsnTinIndicator
	,PmtDays
	,AuthBeginDate
	,AuthEndDate
	,TaxAddressSeq
	,CtrlNum1099
	,SurchargeCode
	,WorkCompNum
	,WorkCompState
	,NCPDPID
	,EntityType
	,LastName
	,FirstName
	,MiddleName
	,Suffix
	,NPI
	,FacilityNPI
	,VerificationGroupID
FROM src.Provider
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


