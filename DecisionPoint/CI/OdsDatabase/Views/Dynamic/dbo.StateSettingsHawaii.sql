IF OBJECT_ID('dbo.StateSettingsHawaii', 'V') IS NOT NULL
    DROP VIEW dbo.StateSettingsHawaii;
GO

CREATE VIEW dbo.StateSettingsHawaii
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,StateSettingsHawaiiId
	,PhysicalMedicineLimitOption
FROM src.StateSettingsHawaii
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


