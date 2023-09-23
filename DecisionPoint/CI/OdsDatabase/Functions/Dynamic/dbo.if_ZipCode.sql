IF OBJECT_ID('dbo.if_ZipCode', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ZipCode;
GO

CREATE FUNCTION dbo.if_ZipCode(
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
	t.ZipCode,
	t.PrimaryRecord,
	t.STATE,
	t.City,
	t.CityAlias,
	t.County,
	t.Cbsa,
	t.CbsaType,
	t.ZipCodeRegionId
FROM src.ZipCode t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ZipCode,
		CityAlias,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ZipCode
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ZipCode,
		CityAlias) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ZipCode = s.ZipCode
	AND t.CityAlias = s.CityAlias
WHERE t.DmlOperation <> 'D';

GO


