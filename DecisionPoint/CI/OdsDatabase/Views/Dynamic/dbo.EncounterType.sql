IF OBJECT_ID('dbo.EncounterType', 'V') IS NOT NULL
    DROP VIEW dbo.EncounterType;
GO

CREATE VIEW dbo.EncounterType
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,EncounterTypeId
	,EncounterTypePriority
	,Description
	,NarrativeInformation
FROM src.EncounterType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


