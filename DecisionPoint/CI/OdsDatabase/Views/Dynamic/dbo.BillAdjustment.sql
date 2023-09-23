IF OBJECT_ID('dbo.BillAdjustment', 'V') IS NOT NULL
    DROP VIEW dbo.BillAdjustment;
GO

CREATE VIEW dbo.BillAdjustment
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillLineAdjustmentId
	,BillIdNo
	,LineNumber
	,Adjustment
	,EndNote
	,EndNoteTypeId
FROM src.BillAdjustment
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


