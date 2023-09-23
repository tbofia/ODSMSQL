IF OBJECT_ID('dbo.Rsn_Override', 'V') IS NOT NULL
    DROP VIEW dbo.Rsn_Override;
GO

CREATE VIEW dbo.Rsn_Override
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
	,ShortDesc
	,LongDesc
	,CategoryIdNo
	,ClientSpec
	,COAIndex
	,NJPenaltyPct
	,NetworkID
	,SpecialProcessing
FROM src.Rsn_Override
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


