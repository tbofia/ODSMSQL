IF OBJECT_ID('dbo.SENTRY_ACTION_CATEGORY', 'V') IS NOT NULL
    DROP VIEW dbo.SENTRY_ACTION_CATEGORY;
GO

CREATE VIEW dbo.SENTRY_ACTION_CATEGORY
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ActionCategoryIDNo
	,Description
FROM src.SENTRY_ACTION_CATEGORY
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


