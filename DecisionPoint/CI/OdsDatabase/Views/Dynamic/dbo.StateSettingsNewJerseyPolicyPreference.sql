IF OBJECT_ID('dbo.StateSettingsNewJerseyPolicyPreference', 'V') IS NOT NULL
    DROP VIEW dbo.StateSettingsNewJerseyPolicyPreference;
GO

CREATE VIEW dbo.StateSettingsNewJerseyPolicyPreference
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PolicyPreferenceId
	,ShareCoPayMaximum
FROM src.StateSettingsNewJerseyPolicyPreference
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


