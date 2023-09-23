IF OBJECT_ID('dbo.Insurer', 'V') IS NOT NULL
    DROP VIEW dbo.Insurer;
GO

CREATE VIEW dbo.Insurer
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,InsurerType
	,InsurerSeq
	,Jurisdiction
	,StateID
	,TIN
	,AltID
	,Name
	,Address1
	,Address2
	,City
	,State
	,Zip
	,PhoneNum
	,CreateUserID
	,CreateDate
	,ModUserID
	,ModDate
	,FaxNum
	,NAICCoCode
	,NAICGpCode
	,NCCICarrierCode
	,NCCIGroupCode
FROM src.Insurer
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


