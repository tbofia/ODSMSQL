IF OBJECT_ID('dbo.Drugs', 'V') IS NOT NULL
    DROP VIEW dbo.Drugs;
GO

CREATE VIEW dbo.Drugs
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,DrugCode
	,DrugsDescription
	,Disp
	,DrugType
	,Cat
	,UpdateFlag
	,Uv
	,CreateDate
	,CreateUserID
	,ModDate
	,ModUserID
FROM src.Drugs
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


