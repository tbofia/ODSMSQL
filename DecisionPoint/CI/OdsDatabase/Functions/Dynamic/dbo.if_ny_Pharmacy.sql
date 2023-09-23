IF OBJECT_ID('dbo.if_ny_pharmacy', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ny_pharmacy;
GO

CREATE FUNCTION dbo.if_ny_pharmacy(
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
	t.NDCCode,
	t.StartDate,
	t.EndDate,
	t.Description,
	t.Fee,
	t.TypeOfDrug
FROM src.ny_pharmacy t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		NDCCode,
		StartDate,
		TypeOfDrug,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ny_pharmacy
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		NDCCode,
		StartDate,
		TypeOfDrug) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.NDCCode = s.NDCCode
	AND t.StartDate = s.StartDate
	AND t.TypeOfDrug = s.TypeOfDrug
WHERE t.DmlOperation <> 'D';

GO


