IF OBJECT_ID('dbo.ProviderNumberCriteria', 'V') IS NOT NULL
    DROP VIEW dbo.ProviderNumberCriteria;
GO

CREATE VIEW dbo.ProviderNumberCriteria
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProviderNumberCriteriaId
	,ProviderNumber
	,Priority
	,FeeScheduleTable
	,StartDate
	,EndDate
FROM src.ProviderNumberCriteria
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


