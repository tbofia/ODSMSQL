IF OBJECT_ID('dbo.if_Provider_ClientRef', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Provider_ClientRef;
GO

CREATE FUNCTION dbo.if_Provider_ClientRef(
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
	t.PvdIdNo,
	t.ClientRefId,
	t.ClientRefId2
FROM src.Provider_ClientRef t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PvdIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Provider_ClientRef
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PvdIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PvdIdNo = s.PvdIdNo
WHERE t.DmlOperation <> 'D';

GO


