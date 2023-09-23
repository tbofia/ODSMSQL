IF OBJECT_ID('dbo.BillProvider', 'V') IS NOT NULL
    DROP VIEW dbo.BillProvider;
GO

CREATE VIEW dbo.BillProvider
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
	,BillProviderSeq
	,Qualifier
	,LastName
	,FirstName
	,MiddleName
	,Suffix
	,NPI
	,LicenseNum
	,DEANum
FROM src.BillProvider
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


