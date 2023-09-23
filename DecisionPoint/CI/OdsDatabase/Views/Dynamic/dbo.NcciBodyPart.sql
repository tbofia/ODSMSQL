IF OBJECT_ID('dbo.NcciBodyPart', 'V') IS NOT NULL
    DROP VIEW dbo.NcciBodyPart;
GO

CREATE VIEW dbo.NcciBodyPart
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
	,Description
	,NarrativeInformation
FROM src.NcciBodyPart
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


