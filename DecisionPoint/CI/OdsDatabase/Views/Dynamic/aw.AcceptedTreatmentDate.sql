IF OBJECT_ID('aw.AcceptedTreatmentDate', 'V') IS NOT NULL
    DROP VIEW aw.AcceptedTreatmentDate;
GO

CREATE VIEW aw.AcceptedTreatmentDate
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,AcceptedTreatmentDateId
	,DemandClaimantId
	,TreatmentDate
	,Comments
	,TreatmentCategoryId
	,LastUpdatedBy
	,LastUpdatedDate
FROM src.AcceptedTreatmentDate
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


