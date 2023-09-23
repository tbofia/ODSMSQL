IF OBJECT_ID('dbo.ModifierByState', 'V') IS NOT NULL
    DROP VIEW dbo.ModifierByState;
GO

CREATE VIEW dbo.ModifierByState
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,State
	,ProcedureServiceCategoryId
	,ModifierDictionaryId
FROM src.ModifierByState
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


