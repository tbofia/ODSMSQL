IF OBJECT_ID('dbo.if_VPNActivityFlag', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_VPNActivityFlag;
GO

CREATE FUNCTION dbo.if_VPNActivityFlag(
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
	t.Activity_Flag,
	t.AF_Description,
	t.AF_ShortDesc,
	t.Data_Source,
	t.Default_Billable,
	t.Credit
FROM src.VPNActivityFlag t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Activity_Flag,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.VPNActivityFlag
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Activity_Flag) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Activity_Flag = s.Activity_Flag
WHERE t.DmlOperation <> 'D';

GO


