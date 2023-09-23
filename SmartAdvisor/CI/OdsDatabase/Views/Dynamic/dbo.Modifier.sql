IF OBJECT_ID('dbo.Modifier', 'V') IS NOT NULL
    DROP VIEW dbo.Modifier;
GO

CREATE VIEW dbo.Modifier
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Jurisdiction
	,Code
	,SiteCode
	,Func
	,Val
	,ModType
	,GroupCode
	,ModDescription
	,ModComment1
	,ModComment2
	,CreateDate
	,CreateUserID
	,ModDate
	,ModUserID
	,Statute
	,Remark1
	,RemarkQualifier1
	,Remark2
	,RemarkQualifier2
	,Remark3
	,RemarkQualifier3
	,Remark4
	,RemarkQualifier4
	,CBREReasonID
FROM src.Modifier
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


