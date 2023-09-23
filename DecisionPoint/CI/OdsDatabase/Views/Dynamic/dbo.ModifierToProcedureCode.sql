IF OBJECT_ID('dbo.ModifierToProcedureCode', 'V') IS NOT NULL
    DROP VIEW dbo.ModifierToProcedureCode;
GO

CREATE VIEW dbo.ModifierToProcedureCode
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProcedureCode
	,Modifier
	,StartDate
	,EndDate
	,SojFlag
	,RequiresGuidelineReview
	,Reference
	,Comments
FROM src.ModifierToProcedureCode
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


