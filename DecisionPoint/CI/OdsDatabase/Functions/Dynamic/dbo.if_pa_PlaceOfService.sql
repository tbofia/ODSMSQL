IF OBJECT_ID('dbo.if_pa_PlaceOfService', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_pa_PlaceOfService;
GO

CREATE FUNCTION dbo.if_pa_PlaceOfService(
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
	t.POS,
	t.Description,
	t.Facility,
	t.MHL,
	t.PlusFour,
	t.Institution
FROM src.pa_PlaceOfService t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		POS,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.pa_PlaceOfService
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		POS) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.POS = s.POS
WHERE t.DmlOperation <> 'D';

GO


