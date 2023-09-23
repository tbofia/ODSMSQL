IF OBJECT_ID('dbo.if_prf_COMPANY', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_prf_COMPANY;
GO

CREATE FUNCTION dbo.if_prf_COMPANY(
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
	t.CompanyName,
	t.LastChangedOn
FROM src.prf_COMPANY t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CompanyId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_COMPANY
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CompanyId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CompanyId = s.CompanyId
WHERE t.DmlOperation <> 'D';

GO


