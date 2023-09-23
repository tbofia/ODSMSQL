IF OBJECT_ID('dbo.RuleType', 'V') IS NOT NULL
    DROP VIEW dbo.RuleType;
GO

CREATE VIEW dbo.RuleType
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,RuleTypeID
	,Name
	,Description
FROM src.RuleType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


