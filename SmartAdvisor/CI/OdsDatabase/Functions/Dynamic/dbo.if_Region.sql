IF OBJECT_ID('dbo.if_Region', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Region;
GO

CREATE FUNCTION dbo.if_Region(
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
	t.Jurisdiction,
	t.Extension,
	t.EndZip,
	t.Beg,
	t.Region,
	t.RegionDescription
FROM src.Region t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Jurisdiction,
		Extension,
		EndZip,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Region
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Jurisdiction,
		Extension,
		EndZip) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Jurisdiction = s.Jurisdiction
	AND t.Extension = s.Extension
	AND t.EndZip = s.EndZip
WHERE t.DmlOperation <> 'D';

GO


