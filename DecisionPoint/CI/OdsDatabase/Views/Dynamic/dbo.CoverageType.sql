IF OBJECT_ID('dbo.CoverageType', 'V') IS NOT NULL
    DROP VIEW dbo.CoverageType;
GO

CREATE VIEW dbo.CoverageType
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,LongName
	,ShortName
	,CbreCoverageTypeCode
	,CoverageTypeCategoryCode
	,PricingMethodId
FROM src.CoverageType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


