IF OBJECT_ID('dbo.FSServiceCode', 'V') IS NOT NULL
    DROP VIEW dbo.FSServiceCode;
GO

CREATE VIEW dbo.FSServiceCode
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Jurisdiction
	,ServiceCode
	,GeoAreaCode
	,EffectiveDate
	,Description
	,TermDate
	,CodeSource
	,CodeGroup
FROM src.FSServiceCode
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


