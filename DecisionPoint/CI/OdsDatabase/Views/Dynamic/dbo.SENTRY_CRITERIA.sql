IF OBJECT_ID('dbo.SENTRY_CRITERIA', 'V') IS NOT NULL
    DROP VIEW dbo.SENTRY_CRITERIA;
GO

CREATE VIEW dbo.SENTRY_CRITERIA
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CriteriaID
	,ParentName
	,Name
	,Description
	,Operators
	,PredefinedValues
	,ValueDataType
	,ValueFormat
	,NullAllowed
FROM src.SENTRY_CRITERIA
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


