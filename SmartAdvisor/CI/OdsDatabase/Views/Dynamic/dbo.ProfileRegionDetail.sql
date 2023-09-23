IF OBJECT_ID('dbo.ProfileRegionDetail', 'V') IS NOT NULL
    DROP VIEW dbo.ProfileRegionDetail;
GO

CREATE VIEW dbo.ProfileRegionDetail
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProfileRegionSiteCode
	,ProfileRegionID
	,ZipCodeFrom
	,ZipCodeTo
FROM src.ProfileRegionDetail
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


