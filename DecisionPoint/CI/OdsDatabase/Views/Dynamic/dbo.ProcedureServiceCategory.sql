IF OBJECT_ID('dbo.ProcedureServiceCategory', 'V') IS NOT NULL
    DROP VIEW dbo.ProcedureServiceCategory;
GO

CREATE VIEW dbo.ProcedureServiceCategory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProcedureServiceCategoryId
	,ProcedureServiceCategoryName
	,ProcedureServiceCategoryDescription
	,LegacyTableName
	,LegacyBitValue
FROM src.ProcedureServiceCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


