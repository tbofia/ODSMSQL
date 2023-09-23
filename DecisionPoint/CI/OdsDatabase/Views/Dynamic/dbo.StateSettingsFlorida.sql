IF OBJECT_ID('dbo.StateSettingsFlorida', 'V') IS NOT NULL
    DROP VIEW dbo.StateSettingsFlorida;
GO

CREATE VIEW dbo.StateSettingsFlorida
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,StateSettingsFloridaId
	,ClaimantInitialServiceOption
	,ClaimantInitialServiceDays
FROM src.StateSettingsFlorida
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


