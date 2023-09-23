IF OBJECT_ID('aw.TreatmentCategoryRange', 'V') IS NOT NULL
    DROP VIEW aw.TreatmentCategoryRange;
GO

CREATE VIEW aw.TreatmentCategoryRange
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,TreatmentCategoryRangeId
	,TreatmentCategoryId
	,StartRange
	,EndRange
FROM src.TreatmentCategoryRange
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


