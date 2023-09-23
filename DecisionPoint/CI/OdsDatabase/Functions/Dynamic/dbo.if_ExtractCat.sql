IF OBJECT_ID('dbo.if_ExtractCat', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ExtractCat;
GO

CREATE FUNCTION dbo.if_ExtractCat(
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
	t.CatIdNo,
	t.Description
FROM src.ExtractCat t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CatIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ExtractCat
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CatIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CatIdNo = s.CatIdNo
WHERE t.DmlOperation <> 'D';

GO


