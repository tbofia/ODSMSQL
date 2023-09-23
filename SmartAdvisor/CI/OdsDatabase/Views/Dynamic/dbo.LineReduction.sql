IF OBJECT_ID('dbo.LineReduction', 'V') IS NOT NULL
    DROP VIEW dbo.LineReduction;
GO

CREATE VIEW dbo.LineReduction
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
	,ReductionCode
	,ReductionAmount
	,OverrideAmount
	,ModUserID
FROM src.LineReduction
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


