IF OBJECT_ID('dbo.CMT_ICD9', 'V') IS NOT NULL
    DROP VIEW dbo.CMT_ICD9;
GO

CREATE VIEW dbo.CMT_ICD9
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillIDNo
	,SeqNo
	,ICD9
	,IcdVersion
FROM src.CMT_ICD9
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


