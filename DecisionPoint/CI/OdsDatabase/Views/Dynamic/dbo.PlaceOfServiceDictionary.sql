IF OBJECT_ID('dbo.PlaceOfServiceDictionary', 'V') IS NOT NULL
    DROP VIEW dbo.PlaceOfServiceDictionary;
GO

CREATE VIEW dbo.PlaceOfServiceDictionary
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PlaceOfServiceCode
	,Description
	,Facility
	,MHL
	,PlusFour
	,Institution
	,StartDate
	,EndDate
FROM src.PlaceOfServiceDictionary
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


