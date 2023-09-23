IF OBJECT_ID('dbo.if_EntityType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_EntityType;
GO

CREATE FUNCTION dbo.if_EntityType(
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
	t.EntityTypeID,
	t.EntityTypeKey,
	t.Description
FROM src.EntityType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EntityTypeID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EntityType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EntityTypeID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EntityTypeID = s.EntityTypeID
WHERE t.DmlOperation <> 'D';

GO


