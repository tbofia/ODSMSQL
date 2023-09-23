IF OBJECT_ID('dbo.SENTRY_RULE_ACTION_DETAIL', 'V') IS NOT NULL
    DROP VIEW dbo.SENTRY_RULE_ACTION_DETAIL;
GO

CREATE VIEW dbo.SENTRY_RULE_ACTION_DETAIL
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
	,LineNumber
	,ActionID
	,ActionValue
FROM src.SENTRY_RULE_ACTION_DETAIL
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


