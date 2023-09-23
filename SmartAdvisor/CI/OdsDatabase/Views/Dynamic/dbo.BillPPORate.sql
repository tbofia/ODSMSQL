IF OBJECT_ID('dbo.BillPPORate', 'V') IS NOT NULL
    DROP VIEW dbo.BillPPORate;
GO

CREATE VIEW dbo.BillPPORate
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
	,LinkName
	,RateType
	,Applied
FROM src.BillPPORate
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


