IF OBJECT_ID('dbo.prf_CTGPenalty', 'V') IS NOT NULL
    DROP VIEW dbo.prf_CTGPenalty;
GO

CREATE VIEW dbo.prf_CTGPenalty
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CTGPenID
	,ProfileId
	,ApplyPreCerts
	,NoPrecertLogged
	,MaxTotalPenalty
	,TurnTimeForAppeals
	,ApplyEndnoteForPercert
	,ApplyEndnoteForCarePath
	,ExemptPrecertPenalty
	,ApplyNetworkPenalty
FROM src.prf_CTGPenalty
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


