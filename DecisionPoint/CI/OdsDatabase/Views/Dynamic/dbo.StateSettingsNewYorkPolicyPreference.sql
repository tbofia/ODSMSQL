IF OBJECT_ID('dbo.StateSettingsNewYorkPolicyPreference', 'V') IS NOT NULL
    DROP VIEW dbo.StateSettingsNewYorkPolicyPreference;
GO

CREATE VIEW dbo.StateSettingsNewYorkPolicyPreference
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
FROM src.StateSettingsNewYorkPolicyPreference
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


