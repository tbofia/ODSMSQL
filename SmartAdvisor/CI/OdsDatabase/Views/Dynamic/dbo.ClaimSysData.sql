IF OBJECT_ID('dbo.ClaimSysData', 'V') IS NOT NULL
    DROP VIEW dbo.ClaimSysData;
GO

CREATE VIEW dbo.ClaimSysData
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClaimSysSubset
	,TypeCode
	,SubType
	,SubSeq
	,NumData
	,TextData
FROM src.ClaimSysData
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


