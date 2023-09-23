IF OBJECT_ID('dbo.lkp_TS', 'V') IS NOT NULL
    DROP VIEW dbo.lkp_TS;
GO

CREATE VIEW dbo.lkp_TS
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ShortName
	,StartDate
	,EndDate
	,LongName
	,Global
	,AnesMedDirect
	,AffectsPricing
	,IsAssistantSurgery
	,IsCoSurgeon
FROM src.lkp_TS
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


