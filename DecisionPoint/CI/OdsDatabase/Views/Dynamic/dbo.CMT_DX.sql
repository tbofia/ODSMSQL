IF OBJECT_ID('dbo.CMT_DX', 'V') IS NOT NULL
    DROP VIEW dbo.CMT_DX;
GO

CREATE VIEW dbo.CMT_DX
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillIDNo
	,DX
	,SeqNum
	,POA
	,IcdVersion
FROM src.CMT_DX
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


