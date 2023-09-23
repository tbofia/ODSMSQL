IF OBJECT_ID('dbo.SENTRY_ACTION', 'V') IS NOT NULL
    DROP VIEW dbo.SENTRY_ACTION;
GO

CREATE VIEW dbo.SENTRY_ACTION
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ActionID
	,Name
	,Description
	,CompatibilityKey
	,PredefinedValues
	,ValueDataType
	,ValueFormat
	,BillLineAction
	,AnalyzeFlag
	,ActionCategoryIDNo
FROM src.SENTRY_ACTION
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


