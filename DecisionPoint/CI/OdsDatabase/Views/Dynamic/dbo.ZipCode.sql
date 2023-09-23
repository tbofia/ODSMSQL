IF OBJECT_ID('dbo.ZipCode', 'V') IS NOT NULL
    DROP VIEW dbo.ZipCode;
GO

CREATE VIEW dbo.ZipCode
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
	,PrimaryRecord
	,STATE
	,City
	,CityAlias
	,County
	,Cbsa
	,CbsaType
	,ZipCodeRegionId
FROM src.ZipCode
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


