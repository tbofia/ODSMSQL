IF OBJECT_ID('dbo.if_ProviderSpecialty', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProviderSpecialty;
GO

CREATE FUNCTION dbo.if_ProviderSpecialty(
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
	t.Id,
	t.Description,
	t.ImplementationDate,
	t.DeactivationDate,
	t.DataSource,
	t.Creator,
	t.CreateDate,
	t.LastUpdater,
	t.LastUpdateDate,
	t.CbrCode
FROM src.ProviderSpecialty t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Id,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderSpecialty
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Id) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Id = s.Id
WHERE t.DmlOperation <> 'D';

GO


