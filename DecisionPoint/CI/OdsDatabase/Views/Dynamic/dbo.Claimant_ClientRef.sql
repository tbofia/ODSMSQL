IF OBJECT_ID('dbo.Claimant_ClientRef', 'V') IS NOT NULL
    DROP VIEW dbo.Claimant_ClientRef;
GO

CREATE VIEW dbo.Claimant_ClientRef
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CmtIdNo
	,CmtSuffix
	,ClaimIdNo
FROM src.Claimant_ClientRef
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


