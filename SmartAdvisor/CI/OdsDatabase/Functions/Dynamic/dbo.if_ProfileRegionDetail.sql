IF OBJECT_ID('dbo.if_ProfileRegionDetail', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProfileRegionDetail;
GO

CREATE FUNCTION dbo.if_ProfileRegionDetail(
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
	t.ProfileRegionSiteCode,
	t.ProfileRegionID,
	t.ZipCodeFrom,
	t.ZipCodeTo
FROM src.ProfileRegionDetail t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProfileRegionSiteCode,
		ProfileRegionID,
		ZipCodeFrom,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProfileRegionDetail
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProfileRegionSiteCode,
		ProfileRegionID,
		ZipCodeFrom) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProfileRegionSiteCode = s.ProfileRegionSiteCode
	AND t.ProfileRegionID = s.ProfileRegionID
	AND t.ZipCodeFrom = s.ZipCodeFrom
WHERE t.DmlOperation <> 'D';

GO


