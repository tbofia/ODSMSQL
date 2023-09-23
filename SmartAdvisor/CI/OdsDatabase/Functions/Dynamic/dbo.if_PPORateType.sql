IF OBJECT_ID('dbo.if_PPORateType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_PPORateType;
GO

CREATE FUNCTION dbo.if_PPORateType(
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
	t.RateTypeCode,
	t.PPONetworkID,
	t.Category,
	t.Priority,
	t.VBColor,
	t.RateTypeDescription,
	t.Explanation
FROM src.PPORateType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RateTypeCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PPORateType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RateTypeCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RateTypeCode = s.RateTypeCode
WHERE t.DmlOperation <> 'D';

GO


