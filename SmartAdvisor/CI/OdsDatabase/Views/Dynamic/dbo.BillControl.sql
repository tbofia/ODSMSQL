IF OBJECT_ID('dbo.BillControl', 'V') IS NOT NULL
    DROP VIEW dbo.BillControl;
GO

CREATE VIEW dbo.BillControl
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClientCode
	,BillSeq
	,BillControlSeq
	,ModDate
	,CreateDate
	,Control
	,ExternalID
	,BatchNumber
	,ModUserID
	,ExternalID2
	,Message
FROM src.BillControl
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


