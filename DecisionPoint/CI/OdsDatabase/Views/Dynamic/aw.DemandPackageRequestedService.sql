IF OBJECT_ID('aw.DemandPackageRequestedService', 'V') IS NOT NULL
    DROP VIEW aw.DemandPackageRequestedService;
GO

CREATE VIEW aw.DemandPackageRequestedService
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,DemandPackageRequestedServiceId
	,DemandPackageId
	,ReviewRequestOptions
FROM src.DemandPackageRequestedService
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


