IF OBJECT_ID('dbo.if_CMS_Zip2Region', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CMS_Zip2Region;
GO

CREATE FUNCTION dbo.if_CMS_Zip2Region(
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
	t.StartDate,
	t.EndDate,
	t.ZIP_Code,
	t.State,
	t.Region,
	t.AmbRegion,
	t.RuralFlag,
	t.ASCRegion,
	t.PlusFour,
	t.CarrierId
FROM src.CMS_Zip2Region t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StartDate,
		ZIP_Code,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CMS_Zip2Region
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StartDate,
		ZIP_Code) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StartDate = s.StartDate
	AND t.ZIP_Code = s.ZIP_Code
WHERE t.DmlOperation <> 'D';

GO


