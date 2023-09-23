IF OBJECT_ID('dbo.Region', 'V') IS NOT NULL
    DROP VIEW dbo.Region;
GO

CREATE VIEW dbo.Region
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Jurisdiction
	,Extension
	,EndZip
	,Beg
	,Region
	,RegionDescription
FROM src.Region
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


