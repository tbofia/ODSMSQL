IF OBJECT_ID('dbo.if_SEC_User_RightGroups', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SEC_User_RightGroups;
GO

CREATE FUNCTION dbo.if_SEC_User_RightGroups(
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
	t.SECUserRightGroupId,
	t.UserId,
	t.RightGroupId
FROM src.SEC_User_RightGroups t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		SECUserRightGroupId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SEC_User_RightGroups
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		SECUserRightGroupId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.SECUserRightGroupId = s.SECUserRightGroupId
WHERE t.DmlOperation <> 'D';

GO


