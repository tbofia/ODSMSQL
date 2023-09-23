IF OBJECT_ID('dbo.if_ProfileRegion', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProfileRegion;
GO

CREATE FUNCTION dbo.if_ProfileRegion(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.SiteCode,
	t.ProfileRegionID,
	t.RegionTypeCode,
	t.RegionName
FROM src.ProfileRegion t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		SiteCode,
		ProfileRegionID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProfileRegion
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		SiteCode,
		ProfileRegionID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.SiteCode = s.SiteCode
	AND t.ProfileRegionID = s.ProfileRegionID
WHERE t.DmlOperation <> 'D';

GO


