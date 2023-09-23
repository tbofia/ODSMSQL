IF OBJECT_ID('dbo.Attorney', 'V') IS NOT NULL
    DROP VIEW dbo.Attorney;
GO

CREATE VIEW dbo.Attorney
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClaimSysSubSet
	,AttorneySeq
	,TIN
	,TINSuffix
	,ExternalID
	,Name
	,GroupCode
	,LicenseNum
	,MedicareNum
	,PracticeAddressSeq
	,BillingAddressSeq
	,AttorneyType
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
FROM src.Attorney
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


