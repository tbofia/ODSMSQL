IF OBJECT_ID('dbo.PractitionerChild', 'V') IS NOT NULL
    DROP VIEW dbo.PractitionerChild;
GO

CREATE VIEW dbo.PractitionerChild
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,SiteCode
	,NPI
	,Qualifier
	,IssuingState
	,SubSeq
	,SecondaryID
	,CreateDate
	,CreateUserID
	,ModDate
	,ModUserID
FROM src.PractitionerChild
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


