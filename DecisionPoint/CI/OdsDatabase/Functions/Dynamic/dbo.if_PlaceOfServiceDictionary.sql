IF OBJECT_ID('dbo.if_PlaceOfServiceDictionary', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_PlaceOfServiceDictionary;
GO

CREATE FUNCTION dbo.if_PlaceOfServiceDictionary(
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
	t.PlaceOfServiceCode,
	t.Description,
	t.Facility,
	t.MHL,
	t.PlusFour,
	t.Institution,
	t.StartDate,
	t.EndDate
FROM src.PlaceOfServiceDictionary t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PlaceOfServiceCode,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PlaceOfServiceDictionary
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PlaceOfServiceCode,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PlaceOfServiceCode = s.PlaceOfServiceCode
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D';

GO


