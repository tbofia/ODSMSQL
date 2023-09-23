IF OBJECT_ID('dbo.UDF_Sentry_Criteria', 'V') IS NOT NULL
    DROP VIEW dbo.UDF_Sentry_Criteria;
GO

CREATE VIEW dbo.UDF_Sentry_Criteria
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,UdfIdNo
	,CriteriaID
	,ParentName
	,Name
	,Description
	,Operators
	,PredefinedValues
	,ValueDataType
	,ValueFormat
FROM src.UDF_Sentry_Criteria
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


