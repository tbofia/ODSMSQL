IF OBJECT_ID('dbo.Bills_Pharm_OverrideEndNotes', 'V') IS NOT NULL
    DROP VIEW dbo.Bills_Pharm_OverrideEndNotes;
GO

CREATE VIEW dbo.Bills_Pharm_OverrideEndNotes
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,OverrideEndNoteID
	,BillIdNo
	,Line_No
	,OverrideEndNote
	,PercentDiscount
	,ActionId
FROM src.Bills_Pharm_OverrideEndNotes
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


