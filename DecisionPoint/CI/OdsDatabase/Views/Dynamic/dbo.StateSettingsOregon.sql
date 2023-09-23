IF OBJECT_ID('dbo.StateSettingsOregon', 'V') IS NOT NULL
    DROP VIEW dbo.StateSettingsOregon;
GO

CREATE VIEW dbo.StateSettingsOregon
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,StateSettingsOregonId
	,ApplyOregonFeeSchedule
FROM src.StateSettingsOregon
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


