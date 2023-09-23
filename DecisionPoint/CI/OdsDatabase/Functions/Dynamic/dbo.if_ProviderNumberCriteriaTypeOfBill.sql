IF OBJECT_ID('dbo.if_ProviderNumberCriteriaTypeOfBill', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProviderNumberCriteriaTypeOfBill;
GO

CREATE FUNCTION dbo.if_ProviderNumberCriteriaTypeOfBill(
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
	t.TypeOfBill,
	t.MatchingProfileNumber,
	t.AttributeMatchTypeId
FROM src.ProviderNumberCriteriaTypeOfBill t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProviderNumberCriteriaId,
		TypeOfBill,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderNumberCriteriaTypeOfBill
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProviderNumberCriteriaId,
		TypeOfBill) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProviderNumberCriteriaId = s.ProviderNumberCriteriaId
	AND t.TypeOfBill = s.TypeOfBill
WHERE t.DmlOperation <> 'D';

GO


