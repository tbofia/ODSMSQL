IF OBJECT_ID('dbo.ProcedureCodeGroup', 'V') IS NOT NULL
    DROP VIEW dbo.ProcedureCodeGroup;
GO

CREATE VIEW dbo.ProcedureCodeGroup
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
	,MajorCategory
	,MinorCategory
FROM src.ProcedureCodeGroup
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


