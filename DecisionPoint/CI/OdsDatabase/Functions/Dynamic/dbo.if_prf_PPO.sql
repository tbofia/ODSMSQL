IF OBJECT_ID('dbo.if_prf_PPO', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_prf_PPO;
GO

CREATE FUNCTION dbo.if_prf_PPO(
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
	t.PPOSysId,
	t.ProfileId,
	t.PPOId,
	t.bStatus,
	t.StartDate,
	t.EndDate,
	t.AutoSend,
	t.AutoResend,
	t.BypassMatching,
	t.UseProviderNetworkEnrollment,
	t.TieredTypeId,
	t.Priority,
	t.PolicyEffectiveDate,
	t.BillFormType
FROM src.prf_PPO t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PPOSysId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_PPO
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PPOSysId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PPOSysId = s.PPOSysId
WHERE t.DmlOperation <> 'D';

GO


