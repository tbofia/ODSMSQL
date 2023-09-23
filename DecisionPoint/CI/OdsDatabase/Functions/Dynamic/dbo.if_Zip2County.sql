IF OBJECT_ID('dbo.if_Zip2County', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Zip2County;
GO

CREATE FUNCTION dbo.if_Zip2County(
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
	t.Zip,
	t.County,
	t.State
FROM src.Zip2County t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Zip,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Zip2County
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Zip) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Zip = s.Zip
WHERE t.DmlOperation <> 'D';

GO


