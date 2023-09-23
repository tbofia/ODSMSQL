IF OBJECT_ID('dbo.if_BillExclusionLookUpTable', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillExclusionLookUpTable;
GO

CREATE FUNCTION dbo.if_BillExclusionLookUpTable(
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
	t.ReportID,
	t.ReportName
FROM src.BillExclusionLookUpTable t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReportID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillExclusionLookUpTable
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReportID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReportID = s.ReportID
WHERE t.DmlOperation <> 'D';

GO


