IF OBJECT_ID('dbo.if_NcciBodyPartToHybridBodyPartTranslation', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_NcciBodyPartToHybridBodyPartTranslation;
GO

CREATE FUNCTION dbo.if_NcciBodyPartToHybridBodyPartTranslation(
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
	t.NcciBodyPartId,
	t.HybridBodyPartId
FROM src.NcciBodyPartToHybridBodyPartTranslation t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		NcciBodyPartId,
		HybridBodyPartId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.NcciBodyPartToHybridBodyPartTranslation
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		NcciBodyPartId,
		HybridBodyPartId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.NcciBodyPartId = s.NcciBodyPartId
	AND t.HybridBodyPartId = s.HybridBodyPartId
WHERE t.DmlOperation <> 'D';

GO


