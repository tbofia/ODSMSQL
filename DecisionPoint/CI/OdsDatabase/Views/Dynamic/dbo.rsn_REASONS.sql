IF OBJECT_ID('dbo.rsn_REASONS', 'V') IS NOT NULL
    DROP VIEW dbo.rsn_REASONS;
GO

CREATE VIEW dbo.rsn_REASONS
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ReasonNumber
	,CV_Type
	,ShortDesc
	,LongDesc
	,CategoryIdNo
	,COAIndex
	,OverrideEndnote
	,HardEdit
	,SpecialProcessing
	,EndnoteActionId
	,RetainForEapg
FROM src.rsn_REASONS
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


