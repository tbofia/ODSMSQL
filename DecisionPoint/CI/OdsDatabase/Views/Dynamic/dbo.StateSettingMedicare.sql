IF OBJECT_ID('dbo.StateSettingMedicare', 'V') IS NOT NULL
    DROP VIEW dbo.StateSettingMedicare;
GO

CREATE VIEW dbo.StateSettingMedicare
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,StateSettingMedicareId
	,PayPercentOfMedicareFee
FROM src.StateSettingMedicare
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


