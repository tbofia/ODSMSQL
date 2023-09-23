IF OBJECT_ID('dbo.if_ProviderSpecialtyToProvType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProviderSpecialtyToProvType;
GO

CREATE FUNCTION dbo.if_ProviderSpecialtyToProvType(
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
	t.ProviderType,
	t.ProviderType_Desc,
	t.Specialty,
	t.Specialty_Desc,
	t.CreateDate,
	t.ModifyDate,
	t.LogicalDelete
FROM src.ProviderSpecialtyToProvType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProviderType,
		Specialty,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderSpecialtyToProvType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProviderType,
		Specialty) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProviderType = s.ProviderType
	AND t.Specialty = s.Specialty
WHERE t.DmlOperation <> 'D';

GO


