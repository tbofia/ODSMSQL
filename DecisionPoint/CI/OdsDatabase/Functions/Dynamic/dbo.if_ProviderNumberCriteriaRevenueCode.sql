IF OBJECT_ID('dbo.if_ProviderNumberCriteriaRevenueCode', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProviderNumberCriteriaRevenueCode;
GO

CREATE FUNCTION dbo.if_ProviderNumberCriteriaRevenueCode(
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
	t.ProviderNumberCriteriaId,
	t.RevenueCode,
	t.MatchingProfileNumber,
	t.AttributeMatchTypeId
FROM src.ProviderNumberCriteriaRevenueCode t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProviderNumberCriteriaId,
		RevenueCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderNumberCriteriaRevenueCode
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProviderNumberCriteriaId,
		RevenueCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProviderNumberCriteriaId = s.ProviderNumberCriteriaId
	AND t.RevenueCode = s.RevenueCode
WHERE t.DmlOperation <> 'D';

GO


