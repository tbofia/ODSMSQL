IF OBJECT_ID('dbo.if_ModifierDictionary', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ModifierDictionary;
GO

CREATE FUNCTION dbo.if_ModifierDictionary(
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
	t.ModifierDictionaryId,
	t.Modifier,
	t.StartDate,
	t.EndDate,
	t.Description,
	t.Global,
	t.AnesMedDirect,
	t.AffectsPricing,
	t.IsCoSurgeon,
	t.IsAssistantSurgery
FROM src.ModifierDictionary t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ModifierDictionaryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ModifierDictionary
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ModifierDictionaryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ModifierDictionaryId = s.ModifierDictionaryId
WHERE t.DmlOperation <> 'D';

GO


