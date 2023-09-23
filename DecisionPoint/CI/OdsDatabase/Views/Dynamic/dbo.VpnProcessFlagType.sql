IF OBJECT_ID('dbo.VpnProcessFlagType', 'V') IS NOT NULL
    DROP VIEW dbo.VpnProcessFlagType;
GO

CREATE VIEW dbo.VpnProcessFlagType
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,VpnProcessFlagTypeId
	,VpnProcessFlagType
FROM src.VpnProcessFlagType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


