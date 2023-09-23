IF OBJECT_ID('dbo.if_StateSettingMedicare', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_StateSettingMedicare;
GO

CREATE FUNCTION dbo.if_StateSettingMedicare(
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
	t.StateSettingMedicareId,
	t.PayPercentOfMedicareFee
FROM src.StateSettingMedicare t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StateSettingMedicareId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingMedicare
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StateSettingMedicareId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StateSettingMedicareId = s.StateSettingMedicareId
WHERE t.DmlOperation <> 'D';

GO


