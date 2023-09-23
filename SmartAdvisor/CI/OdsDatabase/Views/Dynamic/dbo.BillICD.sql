IF OBJECT_ID('dbo.BillICD', 'V') IS NOT NULL
    DROP VIEW dbo.BillICD;
GO

CREATE VIEW dbo.BillICD
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
	,BillICDSeq
	,CodeType
	,ICDCode
	,CodeDate
	,POA
FROM src.BillICD
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


