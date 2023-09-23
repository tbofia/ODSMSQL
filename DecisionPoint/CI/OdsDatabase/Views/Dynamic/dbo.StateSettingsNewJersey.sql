IF OBJECT_ID('dbo.StateSettingsNewJersey', 'V') IS NOT NULL
    DROP VIEW dbo.StateSettingsNewJersey;
GO

CREATE VIEW dbo.StateSettingsNewJersey
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,StateSettingsNewJerseyId
	,ByPassEmergencyServices
FROM src.StateSettingsNewJersey
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


