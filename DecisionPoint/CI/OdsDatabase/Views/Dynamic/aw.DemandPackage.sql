IF OBJECT_ID('aw.DemandPackage', 'V') IS NOT NULL
    DROP VIEW aw.DemandPackage;
GO

CREATE VIEW aw.DemandPackage
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,DemandPackageId
	,DemandClaimantId
	,RequestedByUserName
	,DateTimeReceived
	,CorrelationId
	,PageCount
FROM src.DemandPackage
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


