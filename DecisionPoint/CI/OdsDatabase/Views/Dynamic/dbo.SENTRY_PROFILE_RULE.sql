IF OBJECT_ID('dbo.SENTRY_PROFILE_RULE', 'V') IS NOT NULL
    DROP VIEW dbo.SENTRY_PROFILE_RULE;
GO

CREATE VIEW dbo.SENTRY_PROFILE_RULE
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProfileID
	,RuleID
	,Priority
FROM src.SENTRY_PROFILE_RULE
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


