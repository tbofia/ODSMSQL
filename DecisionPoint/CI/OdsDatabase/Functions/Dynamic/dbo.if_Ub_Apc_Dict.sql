IF OBJECT_ID('dbo.if_UB_APC_DICT', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_UB_APC_DICT;
GO

CREATE FUNCTION dbo.if_UB_APC_DICT(
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
	t.StartDate,
	t.EndDate,
	t.APC,
	t.Description
FROM src.UB_APC_DICT t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		APC,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UB_APC_DICT
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		APC,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.APC = s.APC
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D';

GO


