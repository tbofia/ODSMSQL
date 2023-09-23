IF OBJECT_ID('dbo.if_CustomEndnote', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CustomEndnote;
GO

CREATE FUNCTION dbo.if_CustomEndnote(
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
	t.CustomEndnote,
	t.ShortDescription,
	t.LongDescription
FROM src.CustomEndnote t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CustomEndnote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CustomEndnote
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CustomEndnote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CustomEndnote = s.CustomEndnote
WHERE t.DmlOperation <> 'D';

GO


