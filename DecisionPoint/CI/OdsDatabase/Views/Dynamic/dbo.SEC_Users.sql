IF OBJECT_ID('dbo.SEC_Users', 'V') IS NOT NULL
    DROP VIEW dbo.SEC_Users;
GO

CREATE VIEW dbo.SEC_Users
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,UserId
	,LoginName
	,Password
	,CreatedBy
	,CreatedDate
	,UserStatus
	,FirstName
	,LastName
	,AccountLocked
	,LockedCounter
	,PasswordCreateDate
	,PasswordCaseFlag
	,ePassword
	,CurrentSettings
FROM src.SEC_Users
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


