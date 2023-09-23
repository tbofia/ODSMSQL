IF OBJECT_ID('dbo.Provider_ClientRef', 'V') IS NOT NULL
    DROP VIEW dbo.Provider_ClientRef;
GO

CREATE VIEW dbo.Provider_ClientRef
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PvdIdNo
	,ClientRefId
	,ClientRefId2
FROM src.Provider_ClientRef
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


