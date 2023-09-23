IF OBJECT_ID('dbo.if_Claims_ClientRef', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Claims_ClientRef;
GO

CREATE FUNCTION dbo.if_Claims_ClientRef(
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
	t.ClaimIdNo,
	t.ClientRefId
FROM src.Claims_ClientRef t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Claims_ClientRef
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimIdNo = s.ClaimIdNo
WHERE t.DmlOperation <> 'D';

GO


