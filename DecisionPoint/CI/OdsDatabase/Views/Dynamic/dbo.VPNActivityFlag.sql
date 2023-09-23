IF OBJECT_ID('dbo.VPNActivityFlag', 'V') IS NOT NULL
    DROP VIEW dbo.VPNActivityFlag;
GO

CREATE VIEW dbo.VPNActivityFlag
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Activity_Flag
	,AF_Description
	,AF_ShortDesc
	,Data_Source
	,Default_Billable
	,Credit
FROM src.VPNActivityFlag
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


