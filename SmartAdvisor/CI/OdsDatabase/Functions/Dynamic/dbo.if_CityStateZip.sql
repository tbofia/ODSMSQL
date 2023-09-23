IF OBJECT_ID('dbo.if_CityStateZip', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CityStateZip;
GO

CREATE FUNCTION dbo.if_CityStateZip(
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
	t.CtyStKey,
	t.CpyDtlCode,
	t.ZipClsCode,
	t.CtyStName,
	t.CtyStNameAbv,
	t.CtyStFacCode,
	t.CtyStMailInd,
	t.PreLstCtyKey,
	t.PreLstCtyNme,
	t.CtyDlvInd,
	t.AutZoneInd,
	t.UnqZipInd,
	t.FinanceNum,
	t.StateAbbrv,
	t.CountyNum,
	t.CountyName
FROM src.CityStateZip t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ZipCode,
		CtyStKey,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CityStateZip
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ZipCode,
		CtyStKey) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ZipCode = s.ZipCode
	AND t.CtyStKey = s.CtyStKey
WHERE t.DmlOperation <> 'D';

GO


