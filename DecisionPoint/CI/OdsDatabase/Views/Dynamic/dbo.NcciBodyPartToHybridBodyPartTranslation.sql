IF OBJECT_ID('dbo.NcciBodyPartToHybridBodyPartTranslation', 'V') IS NOT NULL
    DROP VIEW dbo.NcciBodyPartToHybridBodyPartTranslation;
GO

CREATE VIEW dbo.NcciBodyPartToHybridBodyPartTranslation
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,NcciBodyPartId
	,HybridBodyPartId
FROM src.NcciBodyPartToHybridBodyPartTranslation
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


