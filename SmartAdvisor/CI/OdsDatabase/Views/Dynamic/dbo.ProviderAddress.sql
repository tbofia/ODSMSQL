IF OBJECT_ID('dbo.ProviderAddress', 'V') IS NOT NULL
    DROP VIEW dbo.ProviderAddress;
GO

CREATE VIEW dbo.ProviderAddress
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
	,ProviderAddressSeq
	,RecType
	,Address1
	,Address2
	,City
	,State
	,Zip
	,PhoneNum
	,FaxNum
	,ContactFirstName
	,ContactLastName
	,ContactMiddleInitial
	,URFirstName
	,URLastName
	,URMiddleInitial
	,FacilityName
	,CountryCode
	,MailCode
FROM src.ProviderAddress
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


