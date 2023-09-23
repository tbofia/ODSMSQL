IF OBJECT_ID('dbo.pa_PlaceOfService', 'V') IS NOT NULL
    DROP VIEW dbo.pa_PlaceOfService;
GO

CREATE VIEW dbo.pa_PlaceOfService
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,POS
	,Description
	,Facility
	,MHL
	,PlusFour
	,Institution
FROM src.pa_PlaceOfService
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


