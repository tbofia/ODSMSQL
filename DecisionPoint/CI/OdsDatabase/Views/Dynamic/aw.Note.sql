IF OBJECT_ID('aw.Note', 'V') IS NOT NULL
    DROP VIEW aw.Note;
GO

CREATE VIEW aw.Note
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,NoteId
	,DateCreated
	,DateModified
	,CreatedBy
	,ModifiedBy
	,Flag
	,Content
	,NoteContext
	,DemandClaimantId
FROM src.Note
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


