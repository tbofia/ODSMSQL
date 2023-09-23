IF OBJECT_ID('dbo.ScriptAdvisorSettings', 'V') IS NOT NULL
    DROP VIEW dbo.ScriptAdvisorSettings;
GO

CREATE VIEW dbo.ScriptAdvisorSettings
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ScriptAdvisorSettingsId
	,IsPharmacyEligible
	,EnableSendCardToClaimant
	,EnableBillSource
FROM src.ScriptAdvisorSettings
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


