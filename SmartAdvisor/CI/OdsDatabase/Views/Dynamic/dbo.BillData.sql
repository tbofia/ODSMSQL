IF OBJECT_ID('dbo.BillData', 'V') IS NOT NULL
    DROP VIEW dbo.BillData;
GO

CREATE VIEW dbo.BillData
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
	,BillSeq
	,TypeCode
	,SubType
	,SubSeq
	,NumData
	,TextData
	,ModDate
	,ModUserID
	,CreateDate
	,CreateUserID
FROM src.BillData
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


