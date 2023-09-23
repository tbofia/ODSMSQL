IF OBJECT_ID('dbo.ClaimData', 'V') IS NOT NULL
    DROP VIEW dbo.ClaimData;
GO

CREATE VIEW dbo.ClaimData
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
	,ClaimSeq
	,TypeCode
	,SubType
	,SubSeq
	,NumData
	,TextData
	,CreateDate
	,CreateUserID
	,ModDate
	,ModUserID
FROM src.ClaimData
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


