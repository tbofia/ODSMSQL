IF OBJECT_ID('dbo.SEC_User_RightGroups', 'V') IS NOT NULL
    DROP VIEW dbo.SEC_User_RightGroups;
GO

CREATE VIEW dbo.SEC_User_RightGroups
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,SECUserRightGroupId
	,UserId
	,RightGroupId
FROM src.SEC_User_RightGroups
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


