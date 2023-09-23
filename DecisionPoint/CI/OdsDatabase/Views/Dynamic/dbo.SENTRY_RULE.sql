IF OBJECT_ID('dbo.SENTRY_RULE', 'V') IS NOT NULL
    DROP VIEW dbo.SENTRY_RULE;
GO

CREATE VIEW dbo.SENTRY_RULE
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,RuleID
	,Name
	,Description
	,CreatedBy
	,CreationDate
	,PostFixNotation
	,Priority
	,RuleTypeID
FROM src.SENTRY_RULE
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


