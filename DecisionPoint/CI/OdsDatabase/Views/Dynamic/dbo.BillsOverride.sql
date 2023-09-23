IF OBJECT_ID('dbo.BillsOverride', 'V') IS NOT NULL
    DROP VIEW dbo.BillsOverride;
GO

CREATE VIEW dbo.BillsOverride
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillsOverrideID
	,BillIDNo
	,LINE_NO
	,UserId
	,DateSaved
	,AmountBefore
	,AmountAfter
	,CodesOverrode
	,SeqNo
FROM src.BillsOverride
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


