IF OBJECT_ID('dbo.Branch', 'V') IS NOT NULL
    DROP VIEW dbo.Branch;
GO

CREATE VIEW dbo.Branch
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
	,BranchSeq
	,Name
	,ExternalID
	,BranchID
	,LocationCode
	,AdminKey
	,Address1
	,Address2
	,City
	,State
	,Zip
	,PhoneNum
	,FaxNum
	,ContactName
	,TIN
	,StateTaxID
	,DIRNum
	,ModUserID
	,ModDate
	,RuleFire
	,FeeRateCntrlEx
	,FeeRateCntrlIn
	,SalesTaxExempt
	,EffectiveDate
	,TerminationDate
FROM src.Branch
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


