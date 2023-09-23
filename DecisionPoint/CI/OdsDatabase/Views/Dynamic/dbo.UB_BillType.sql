IF OBJECT_ID('dbo.UB_BillType', 'V') IS NOT NULL
    DROP VIEW dbo.UB_BillType;
GO

CREATE VIEW dbo.UB_BillType
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,TOB
	,Description
	,Flag
	,UB_BillTypeID
FROM src.UB_BillType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


