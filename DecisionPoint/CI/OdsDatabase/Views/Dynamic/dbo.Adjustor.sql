IF OBJECT_ID('dbo.Adjustor', 'V') IS NOT NULL
    DROP VIEW dbo.Adjustor;
GO

CREATE VIEW dbo.Adjustor
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,lAdjIdNo
	,IDNumber
	,Lastname
	,FirstName
	,Address1
	,Address2
	,City
	,State
	,ZipCode
	,Phone
	,Fax
	,Office
	,EMail
	,InUse
	,OfficeIdNo
	,UserId
	,CreateDate
	,LastChangedOn
FROM src.Adjustor
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


