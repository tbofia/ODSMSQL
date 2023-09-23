IF OBJECT_ID('dbo.ClaimDiag', 'V') IS NOT NULL
    DROP VIEW dbo.ClaimDiag;
GO

CREATE VIEW dbo.ClaimDiag
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClaimSysSubSet
	,ClaimSeq
	,ClaimDiagSeq
	,DiagCode
FROM src.ClaimDiag
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


