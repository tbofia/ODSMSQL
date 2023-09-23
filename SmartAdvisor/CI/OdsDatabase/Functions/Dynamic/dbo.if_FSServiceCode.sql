IF OBJECT_ID('dbo.if_FSServiceCode', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_FSServiceCode;
GO

CREATE FUNCTION dbo.if_FSServiceCode(
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
	t.ServiceCode,
	t.GeoAreaCode,
	t.EffectiveDate,
	t.Description,
	t.TermDate,
	t.CodeSource,
	t.CodeGroup
FROM src.FSServiceCode t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Jurisdiction,
		ServiceCode,
		GeoAreaCode,
		EffectiveDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.FSServiceCode
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Jurisdiction,
		ServiceCode,
		GeoAreaCode,
		EffectiveDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Jurisdiction = s.Jurisdiction
	AND t.ServiceCode = s.ServiceCode
	AND t.GeoAreaCode = s.GeoAreaCode
	AND t.EffectiveDate = s.EffectiveDate
WHERE t.DmlOperation <> 'D';

GO


