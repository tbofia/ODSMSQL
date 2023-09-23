IF OBJECT_ID('dbo.SENTRY_RULE_ACTION_HEADER', 'V') IS NOT NULL
    DROP VIEW dbo.SENTRY_RULE_ACTION_HEADER;
GO

CREATE VIEW dbo.SENTRY_RULE_ACTION_HEADER
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
	,EndnoteShort
	,EndnoteLong
FROM src.SENTRY_RULE_ACTION_HEADER
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


