IF OBJECT_ID('dbo.RevenueCode', 'V') IS NOT NULL
    DROP VIEW dbo.RevenueCode;
GO

CREATE VIEW dbo.RevenueCode
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,RevenueCode
	,RevenueCodeSubCategoryId
FROM src.RevenueCode
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


