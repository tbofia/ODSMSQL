IF OBJECT_ID('dbo.if_SEC_User_OfficeGroups', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SEC_User_OfficeGroups;
GO

CREATE FUNCTION dbo.if_SEC_User_OfficeGroups(
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
	t.SECUserOfficeGroupId,
	t.UserId,
	t.OffcGroupId
FROM src.SEC_User_OfficeGroups t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		SECUserOfficeGroupId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SEC_User_OfficeGroups
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		SECUserOfficeGroupId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.SECUserOfficeGroupId = s.SECUserOfficeGroupId
WHERE t.DmlOperation <> 'D';

GO


