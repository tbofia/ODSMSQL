IF OBJECT_ID('dbo.if_Bills_OverrideEndNotes', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Bills_OverrideEndNotes;
GO

CREATE FUNCTION dbo.if_Bills_OverrideEndNotes(
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
	t.OverrideEndNoteID,
	t.BillIdNo,
	t.Line_No,
	t.OverrideEndNote,
	t.PercentDiscount,
	t.ActionId
FROM src.Bills_OverrideEndNotes t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		OverrideEndNoteID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bills_OverrideEndNotes
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		OverrideEndNoteID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.OverrideEndNoteID = s.OverrideEndNoteID
WHERE t.DmlOperation <> 'D';

GO


