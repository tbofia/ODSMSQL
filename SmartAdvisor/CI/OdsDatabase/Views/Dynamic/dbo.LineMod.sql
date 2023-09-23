IF OBJECT_ID('dbo.LineMod', 'V') IS NOT NULL
    DROP VIEW dbo.LineMod;
GO

CREATE VIEW dbo.LineMod
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
	,LineSeq
	,ModSeq
	,UserEntered
	,ModSiteCode
	,Modifier
	,ReductionCode
	,ModSubset
	,ModUserID
	,ModDate
	,ReasonClientCode
	,ReasonBillSeq
	,ReasonLineSeq
	,ReasonType
	,ReasonValue
FROM src.LineMod
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


