IF OBJECT_ID('dbo.ProfileRegion', 'V') IS NOT NULL
    DROP VIEW dbo.ProfileRegion;
GO

CREATE VIEW dbo.ProfileRegion
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,SiteCode
	,ProfileRegionID
	,RegionTypeCode
	,RegionName
FROM src.ProfileRegion
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


