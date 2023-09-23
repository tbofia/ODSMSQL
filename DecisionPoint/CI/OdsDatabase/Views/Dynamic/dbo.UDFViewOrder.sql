IF OBJECT_ID('dbo.UDFViewOrder', 'V') IS NOT NULL
    DROP VIEW dbo.UDFViewOrder;
GO

CREATE VIEW dbo.UDFViewOrder
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,OfficeId
	,UDFIdNo
	,ViewOrder
FROM src.UDFViewOrder
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


