IF OBJECT_ID('dbo.SEC_RightGroups', 'V') IS NOT NULL
    DROP VIEW dbo.SEC_RightGroups;
GO

CREATE VIEW dbo.SEC_RightGroups
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,RightGroupId
	,RightGroupName
	,RightGroupDescription
	,CreatedDate
	,CreatedBy
FROM src.SEC_RightGroups
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


