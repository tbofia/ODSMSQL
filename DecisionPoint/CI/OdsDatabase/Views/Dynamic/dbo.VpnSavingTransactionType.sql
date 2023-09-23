IF OBJECT_ID('dbo.VpnSavingTransactionType', 'V') IS NOT NULL
    DROP VIEW dbo.VpnSavingTransactionType;
GO

CREATE VIEW dbo.VpnSavingTransactionType
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,VpnSavingTransactionTypeId
	,VpnSavingTransactionType
FROM src.VpnSavingTransactionType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


