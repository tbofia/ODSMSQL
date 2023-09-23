IF OBJECT_ID('dbo.Claims_ClientRef', 'V') IS NOT NULL
    DROP VIEW dbo.Claims_ClientRef;
GO

CREATE VIEW dbo.Claims_ClientRef
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClaimIdNo
	,ClientRefId
FROM src.Claims_ClientRef
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


