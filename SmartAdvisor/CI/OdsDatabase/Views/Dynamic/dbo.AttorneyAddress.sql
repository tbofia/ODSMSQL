IF OBJECT_ID('dbo.AttorneyAddress', 'V') IS NOT NULL
    DROP VIEW dbo.AttorneyAddress;
GO

CREATE VIEW dbo.AttorneyAddress
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
	,AttorneyAddressSeq
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
FROM src.AttorneyAddress
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


