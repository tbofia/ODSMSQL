IF OBJECT_ID('dbo.if_Adjuster', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Adjuster;
GO

CREATE FUNCTION dbo.if_Adjuster(
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
	t.ClaimSysSubSet,
	t.Adjuster,
	t.FirstName,
	t.LastName,
	t.MInitial,
	t.Title,
	t.Address1,
	t.Address2,
	t.City,
	t.State,
	t.Zip,
	t.PhoneNum,
	t.PhoneNumExt,
	t.FaxNum,
	t.Email,
	t.CreateDate,
	t.CreateUserID,
	t.ModDate,
	t.ModUserID
FROM src.Adjuster t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimSysSubSet,
		Adjuster,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Adjuster
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimSysSubSet,
		Adjuster) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimSysSubSet = s.ClaimSysSubSet
	AND t.Adjuster = s.Adjuster
WHERE t.DmlOperation <> 'D';

GO


