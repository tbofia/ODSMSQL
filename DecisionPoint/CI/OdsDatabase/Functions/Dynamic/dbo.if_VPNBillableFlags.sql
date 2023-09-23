IF OBJECT_ID('dbo.if_VpnBillableFlags', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_VpnBillableFlags;
GO

CREATE FUNCTION dbo.if_VpnBillableFlags(
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
	t.SOJ,
	t.NetworkID,
	t.ActivityFlag,
	t.Billable,
	t.CompanyCode,
	t.CompanyName
FROM src.VpnBillableFlags t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CompanyCode,
		SOJ,
		NetworkID,
		ActivityFlag,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.VpnBillableFlags
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CompanyCode,
		SOJ,
		NetworkID,
		ActivityFlag) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CompanyCode = s.CompanyCode
	AND t.SOJ = s.SOJ
	AND t.NetworkID = s.NetworkID
	AND t.ActivityFlag = s.ActivityFlag
WHERE t.DmlOperation <> 'D';

GO


