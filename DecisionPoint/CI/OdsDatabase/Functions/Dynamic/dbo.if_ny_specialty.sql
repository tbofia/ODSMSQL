IF OBJECT_ID('dbo.if_ny_specialty', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ny_specialty;
GO

CREATE FUNCTION dbo.if_ny_specialty(
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
	t.RatingCode,
	t.Desc_,
	t.CbreSpecialtyCode
FROM src.ny_specialty t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RatingCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ny_specialty
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RatingCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RatingCode = s.RatingCode
WHERE t.DmlOperation <> 'D';

GO


