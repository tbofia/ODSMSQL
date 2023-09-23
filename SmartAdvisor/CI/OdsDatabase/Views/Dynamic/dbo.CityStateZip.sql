IF OBJECT_ID('dbo.CityStateZip', 'V') IS NOT NULL
    DROP VIEW dbo.CityStateZip;
GO

CREATE VIEW dbo.CityStateZip
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ZipCode
	,CtyStKey
	,CpyDtlCode
	,ZipClsCode
	,CtyStName
	,CtyStNameAbv
	,CtyStFacCode
	,CtyStMailInd
	,PreLstCtyKey
	,PreLstCtyNme
	,CtyDlvInd
	,AutZoneInd
	,UnqZipInd
	,FinanceNum
	,StateAbbrv
	,CountyNum
	,CountyName
FROM src.CityStateZip
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


