IF OBJECT_ID('aw.TreatmentCategory', 'V') IS NOT NULL
    DROP VIEW aw.TreatmentCategory;
GO

CREATE VIEW aw.TreatmentCategory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,TreatmentCategoryId
	,Category
	,Metadata
FROM src.TreatmentCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


