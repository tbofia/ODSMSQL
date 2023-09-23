IF OBJECT_ID('dbo.if_SEC_RightGroups', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SEC_RightGroups;
GO

CREATE FUNCTION dbo.if_SEC_RightGroups(
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
	t.RightGroupId,
	t.RightGroupName,
	t.RightGroupDescription,
	t.CreatedDate,
	t.CreatedBy
FROM src.SEC_RightGroups t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RightGroupId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SEC_RightGroups
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RightGroupId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RightGroupId = s.RightGroupId
WHERE t.DmlOperation <> 'D';

GO


