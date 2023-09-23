IF OBJECT_ID('dbo.CustomBillStatuses', 'V') IS NOT NULL
    DROP VIEW dbo.CustomBillStatuses;
GO

CREATE VIEW dbo.CustomBillStatuses
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,StatusId
	,StatusName
	,StatusDescription
FROM src.CustomBillStatuses
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


