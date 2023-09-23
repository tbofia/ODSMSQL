IF OBJECT_ID('dbo.ClientData', 'V') IS NOT NULL
    DROP VIEW dbo.ClientData;
GO

CREATE VIEW dbo.ClientData
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClientCode
	,TypeCode
	,SubType
	,SubSeq
	,NumData
	,TextData
	,CreateDate
	,CreateUserID
	,ModDate
	,ModUserID
FROM src.ClientData
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


