IF OBJECT_ID('dbo.if_MedicareStatusIndicatorRulePlaceOfService', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_MedicareStatusIndicatorRulePlaceOfService;
GO

CREATE FUNCTION dbo.if_MedicareStatusIndicatorRulePlaceOfService(
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
	t.MedicareStatusIndicatorRuleId,
	t.PlaceOfService
FROM src.MedicareStatusIndicatorRulePlaceOfService t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		PlaceOfService,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.MedicareStatusIndicatorRulePlaceOfService
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		PlaceOfService) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.MedicareStatusIndicatorRuleId = s.MedicareStatusIndicatorRuleId
	AND t.PlaceOfService = s.PlaceOfService
WHERE t.DmlOperation <> 'D';

GO


