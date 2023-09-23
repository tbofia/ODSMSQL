IF OBJECT_ID('dbo.SEC_User_OfficeGroups', 'V') IS NOT NULL
    DROP VIEW dbo.SEC_User_OfficeGroups;
GO

CREATE VIEW dbo.SEC_User_OfficeGroups
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,SECUserOfficeGroupId
	,UserId
	,OffcGroupId
FROM src.SEC_User_OfficeGroups
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


