IF OBJECT_ID('dbo.UB_APC_DICT', 'V') IS NOT NULL
    DROP VIEW dbo.UB_APC_DICT;
GO

CREATE VIEW dbo.UB_APC_DICT
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,StartDate
	,EndDate
	,APC
	,Description
FROM src.UB_APC_DICT
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


