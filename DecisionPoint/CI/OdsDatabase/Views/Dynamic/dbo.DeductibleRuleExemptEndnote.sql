IF OBJECT_ID('dbo.DeductibleRuleExemptEndnote', 'V') IS NOT NULL
    DROP VIEW dbo.DeductibleRuleExemptEndnote;
GO

CREATE VIEW dbo.DeductibleRuleExemptEndnote
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
FROM src.DeductibleRuleExemptEndnote
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


