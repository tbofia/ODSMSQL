IF OBJECT_ID('dbo.Practitioner', 'V') IS NOT NULL
    DROP VIEW dbo.Practitioner;
GO

CREATE VIEW dbo.Practitioner
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,SiteCode
	,NPI
	,EntityTypeCode
	,Name
	,FirstName
	,LastName
	,MiddleName
	,Suffix
	,NameOther
	,MailingAddress1
	,MailingAddress2
	,MailingCity
	,MailingState
	,MailingZip
	,PracticeAddress1
	,PracticeAddress2
	,PracticeCity
	,PracticeState
	,PracticeZip
	,EnumerationDate
	,DeactivationReasonCode
	,DeactivationDate
	,ReactivationDate
	,Gender
	,CreateDate
	,CreateUserID
	,ModDate
	,ModUserID
FROM src.Practitioner
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


