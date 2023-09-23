IF OBJECT_ID('dbo.prf_COMPANY', 'V') IS NOT NULL
    DROP VIEW dbo.prf_COMPANY;
GO

CREATE VIEW dbo.prf_COMPANY
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CompanyId
	,CompanyName
	,LastChangedOn
FROM src.prf_COMPANY
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


