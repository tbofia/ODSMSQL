IF OBJECT_ID('dbo.BillsProviderNetwork', 'V') IS NOT NULL
    DROP VIEW dbo.BillsProviderNetwork;
GO

CREATE VIEW dbo.BillsProviderNetwork
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillIdNo
	,NetworkId
	,NetworkName
FROM src.BillsProviderNetwork
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


