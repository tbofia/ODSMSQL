IF OBJECT_ID('dbo.if_VpnSavingTransactionType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_VpnSavingTransactionType;
GO

CREATE FUNCTION dbo.if_VpnSavingTransactionType(
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
	t.VpnSavingTransactionTypeId,
	t.VpnSavingTransactionType
FROM src.VpnSavingTransactionType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		VpnSavingTransactionTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.VpnSavingTransactionType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		VpnSavingTransactionTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.VpnSavingTransactionTypeId = s.VpnSavingTransactionTypeId
WHERE t.DmlOperation <> 'D';

GO


