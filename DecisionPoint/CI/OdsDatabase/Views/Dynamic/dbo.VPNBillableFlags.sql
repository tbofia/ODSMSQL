IF OBJECT_ID('dbo.VpnBillableFlags', 'V') IS NOT NULL
    DROP VIEW dbo.VpnBillableFlags;
GO

CREATE VIEW dbo.VpnBillableFlags
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,SOJ
	,NetworkID
	,ActivityFlag
	,Billable
	,CompanyCode
	,CompanyName
FROM src.VpnBillableFlags
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


