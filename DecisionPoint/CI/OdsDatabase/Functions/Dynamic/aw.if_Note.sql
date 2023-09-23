IF OBJECT_ID('aw.if_Note', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_Note;
GO

CREATE FUNCTION aw.if_Note(
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
	t.NoteId,
	t.DateCreated,
	t.DateModified,
	t.CreatedBy,
	t.ModifiedBy,
	t.Flag,
	t.Content,
	t.NoteContext,
	t.DemandClaimantId
FROM src.Note t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		NoteId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Note
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		NoteId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.NoteId = s.NoteId
WHERE t.DmlOperation <> 'D';

GO


