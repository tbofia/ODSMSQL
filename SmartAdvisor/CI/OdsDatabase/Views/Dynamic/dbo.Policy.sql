IF OBJECT_ID('dbo.Policy', 'V') IS NOT NULL
    DROP VIEW dbo.Policy;
GO

CREATE VIEW dbo.Policy
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
	,PolicySeq
	,Name
	,ExternalID
	,PolicyID
	,AdminKey
	,LocationCode
	,Address1
	,Address2
	,City
	,State
	,Zip
	,PhoneNum
	,FaxNum
	,EffectiveDate
	,TerminationDate
	,TIN
	,StateTaxID
	,DeptIndusRelNum
	,EqOppIndicator
	,ModUserID
	,ModDate
	,MCOFlag
	,MCOStartDate
	,FeeRateCtrlEx
	,CreateBy
	,FeeRateCtrlIn
	,CreateDate
	,SelfInsured
	,NAICSCode
	,MonthlyPremium
	,PPOProfileSiteCode
	,PPOProfileID
	,SalesTaxExempt
	,ReceiptHandlingCode
	,TxNonSubscrib
	,SubdivisionName
	,PolicyCoPayAmount
	,PolicyCoPayPct
	,PolicyDeductible
	,PolicyLimitAmount
	,PolicyTimeLimit
	,PolicyLimitWarningPct
	,PolicyLimitResult
	,URProfileID
FROM src.Policy
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


