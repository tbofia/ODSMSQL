IF OBJECT_ID('dbo.if_WFTaskRegistry', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_WFTaskRegistry;
GO

CREATE FUNCTION dbo.if_WFTaskRegistry(
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
	t.WFTaskRegistrySeq,
	t.EntityTypeCode,
	t.Description,
	t.Action,
	t.SmallImageResID,
	t.LargeImageResID,
	t.PersistBefore,
	t.NAction
FROM src.WFTaskRegistry t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		WFTaskRegistrySeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.WFTaskRegistry
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		WFTaskRegistrySeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.WFTaskRegistrySeq = s.WFTaskRegistrySeq
WHERE t.DmlOperation <> 'D';

GO


