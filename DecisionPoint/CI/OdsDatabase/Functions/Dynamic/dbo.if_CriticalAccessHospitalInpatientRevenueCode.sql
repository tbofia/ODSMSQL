IF OBJECT_ID('dbo.if_CriticalAccessHospitalInpatientRevenueCode', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CriticalAccessHospitalInpatientRevenueCode;
GO

CREATE FUNCTION dbo.if_CriticalAccessHospitalInpatientRevenueCode(
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
	t.RevenueCode
FROM src.CriticalAccessHospitalInpatientRevenueCode t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RevenueCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CriticalAccessHospitalInpatientRevenueCode
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RevenueCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RevenueCode = s.RevenueCode
WHERE t.DmlOperation <> 'D';

GO


