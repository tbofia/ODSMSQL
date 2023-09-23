IF OBJECT_ID('aw.DemandClaimant', 'V') IS NOT NULL
    DROP VIEW aw.DemandClaimant;
GO

CREATE VIEW aw.DemandClaimant
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,DemandClaimantId
	,ExternalClaimantId
	,OrganizationId
	,HeightInInches
	,Weight
	,Occupation
	,BiReportStatus
	,HasDemandPackage
	,FactsOfLoss
	,PreExistingConditions
	,Archived
FROM src.DemandClaimant
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


