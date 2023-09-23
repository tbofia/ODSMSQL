IF OBJECT_ID('dbo.ApportionmentEndnote', 'V') IS NOT NULL
    DROP VIEW dbo.ApportionmentEndnote;
GO

CREATE VIEW dbo.ApportionmentEndnote
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ApportionmentEndnote
	,ShortDescription
	,LongDescription
FROM src.ApportionmentEndnote
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


