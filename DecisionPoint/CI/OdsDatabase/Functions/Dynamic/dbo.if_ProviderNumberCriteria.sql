IF OBJECT_ID('dbo.if_ProviderNumberCriteria', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProviderNumberCriteria;
GO

CREATE FUNCTION dbo.if_ProviderNumberCriteria(
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
	t.ProviderNumber,
	t.Priority,
	t.FeeScheduleTable,
	t.StartDate,
	t.EndDate
FROM src.ProviderNumberCriteria t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProviderNumberCriteriaId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderNumberCriteria
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProviderNumberCriteriaId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProviderNumberCriteriaId = s.ProviderNumberCriteriaId
WHERE t.DmlOperation <> 'D';

GO


