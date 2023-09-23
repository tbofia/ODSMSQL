IF OBJECT_ID('dbo.prf_PPO', 'V') IS NOT NULL
    DROP VIEW dbo.prf_PPO;
GO

CREATE VIEW dbo.prf_PPO
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PPOSysId
	,ProfileId
	,PPOId
	,bStatus
	,StartDate
	,EndDate
	,AutoSend
	,AutoResend
	,BypassMatching
	,UseProviderNetworkEnrollment
	,TieredTypeId
	,Priority
	,PolicyEffectiveDate
	,BillFormType
FROM src.prf_PPO
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


