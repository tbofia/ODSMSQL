IF OBJECT_ID('dbo.Adjuster', 'V') IS NOT NULL
    DROP VIEW dbo.Adjuster;
GO

CREATE VIEW dbo.Adjuster
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
	,Adjuster
	,FirstName
	,LastName
	,MInitial
	,Title
	,Address1
	,Address2
	,City
	,State
	,Zip
	,PhoneNum
	,PhoneNumExt
	,FaxNum
	,Email
	,CreateDate
	,CreateUserID
	,ModDate
	,ModUserID
FROM src.Adjuster
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


