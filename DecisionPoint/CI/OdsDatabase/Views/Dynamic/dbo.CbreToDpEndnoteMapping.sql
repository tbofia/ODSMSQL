IF OBJECT_ID('dbo.CbreToDpEndnoteMapping', 'V') IS NOT NULL
    DROP VIEW dbo.CbreToDpEndnoteMapping;
GO

CREATE VIEW dbo.CbreToDpEndnoteMapping
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Endnote
	,EndnoteTypeId
	,CbreEndnote
	,PricingState
	,PricingMethodId
FROM src.CbreToDpEndnoteMapping
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


