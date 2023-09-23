IF OBJECT_ID('dbo.if_prf_Office', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_prf_Office;
GO

CREATE FUNCTION dbo.if_prf_Office(
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
	t.CompanyId,
	t.OfficeId,
	t.OfcNo,
	t.OfcName,
	t.OfcAddr1,
	t.OfcAddr2,
	t.OfcCity,
	t.OfcState,
	t.OfcZip,
	t.OfcPhone,
	t.OfcDefault,
	t.OfcClaimMask,
	t.OfcTinMask,
	t.Version,
	t.OfcEdits,
	t.OfcCOAEnabled,
	t.CTGEnabled,
	t.LastChangedOn,
	t.AllowMultiCoverage
FROM src.prf_Office t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		OfficeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_Office
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		OfficeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.OfficeId = s.OfficeId
WHERE t.DmlOperation <> 'D';

GO


