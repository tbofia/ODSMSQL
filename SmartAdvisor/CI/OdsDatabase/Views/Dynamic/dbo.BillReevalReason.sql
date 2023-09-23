IF OBJECT_ID('dbo.BillReevalReason', 'V') IS NOT NULL
    DROP VIEW dbo.BillReevalReason;
GO

CREATE VIEW dbo.BillReevalReason
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillReevalReasonCode
	,SiteCode
	,BillReevalReasonCategorySeq
	,ShortDescription
	,LongDescription
	,Active
	,CreateDate
	,CreateUserID
	,ModDate
	,ModUserID
FROM src.BillReevalReason
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


