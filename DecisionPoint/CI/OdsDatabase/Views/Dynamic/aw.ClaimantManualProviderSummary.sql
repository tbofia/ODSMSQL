IF OBJECT_ID('aw.ClaimantManualProviderSummary', 'V') IS NOT NULL
    DROP VIEW aw.ClaimantManualProviderSummary;
GO

CREATE VIEW aw.ClaimantManualProviderSummary
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ManualProviderId
	,DemandClaimantId
	,FirstDateOfService
	,LastDateOfService
	,Visits
	,ChargedAmount
	,EvaluatedAmount
	,MinimumEvaluatedAmount
	,MaximumEvaluatedAmount
	,Comments
FROM src.ClaimantManualProviderSummary
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


