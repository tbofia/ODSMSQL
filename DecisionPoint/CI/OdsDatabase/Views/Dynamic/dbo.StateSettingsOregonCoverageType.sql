IF OBJECT_ID('dbo.StateSettingsOregonCoverageType', 'V') IS NOT NULL
    DROP VIEW dbo.StateSettingsOregonCoverageType;
GO

CREATE VIEW dbo.StateSettingsOregonCoverageType
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
	,CoverageType
FROM src.StateSettingsOregonCoverageType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


