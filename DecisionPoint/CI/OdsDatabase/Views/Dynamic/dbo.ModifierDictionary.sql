IF OBJECT_ID('dbo.ModifierDictionary', 'V') IS NOT NULL
    DROP VIEW dbo.ModifierDictionary;
GO

CREATE VIEW dbo.ModifierDictionary
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ModifierDictionaryId
	,Modifier
	,StartDate
	,EndDate
	,Description
	,Global
	,AnesMedDirect
	,AffectsPricing
	,IsCoSurgeon
	,IsAssistantSurgery
FROM src.ModifierDictionary
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


