IF OBJECT_ID('dbo.if_SEC_Users', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SEC_Users;
GO

CREATE FUNCTION dbo.if_SEC_Users(
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
	t.UserId,
	t.LoginName,
	t.Password,
	t.CreatedBy,
	t.CreatedDate,
	t.UserStatus,
	t.FirstName,
	t.LastName,
	t.AccountLocked,
	t.LockedCounter,
	t.PasswordCreateDate,
	t.PasswordCaseFlag,
	t.ePassword,
	t.CurrentSettings
FROM src.SEC_Users t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		UserId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SEC_Users
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		UserId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.UserId = s.UserId
WHERE t.DmlOperation <> 'D';

GO


