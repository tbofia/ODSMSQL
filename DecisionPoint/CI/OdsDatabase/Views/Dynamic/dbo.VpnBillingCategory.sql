IF OBJECT_ID('dbo.VpnBillingCategory', 'V') IS NOT NULL
    DROP VIEW dbo.VpnBillingCategory;
GO

CREATE VIEW dbo.VpnBillingCategory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,VpnBillingCategoryCode
	,VpnBillingCategoryDescription
FROM src.VpnBillingCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


