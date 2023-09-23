IF OBJECT_ID('dbo.if_Claimant_ClientRef', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Claimant_ClientRef;
GO

CREATE FUNCTION dbo.if_Claimant_ClientRef(
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
	t.CmtIdNo,
	t.CmtSuffix,
	t.ClaimIdNo
FROM src.Claimant_ClientRef t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CmtIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Claimant_ClientRef
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CmtIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CmtIdNo = s.CmtIdNo
WHERE t.DmlOperation <> 'D';

GO


