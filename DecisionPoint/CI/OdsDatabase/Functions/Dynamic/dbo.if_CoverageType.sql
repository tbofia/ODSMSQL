IF OBJECT_ID('dbo.if_CoverageType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CoverageType;
GO

CREATE FUNCTION dbo.if_CoverageType(
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
	t.LongName,
	t.ShortName,
	t.CbreCoverageTypeCode,
	t.CoverageTypeCategoryCode,
	t.PricingMethodId
FROM src.CoverageType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ShortName,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CoverageType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ShortName) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ShortName = s.ShortName
WHERE t.DmlOperation <> 'D';

GO


