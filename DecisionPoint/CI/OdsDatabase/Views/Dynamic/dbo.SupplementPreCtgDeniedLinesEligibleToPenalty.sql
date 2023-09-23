IF OBJECT_ID('dbo.SupplementPreCtgDeniedLinesEligibleToPenalty', 'V') IS NOT NULL
    DROP VIEW dbo.SupplementPreCtgDeniedLinesEligibleToPenalty;
GO

CREATE VIEW dbo.SupplementPreCtgDeniedLinesEligibleToPenalty
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillIdNo
	,LineNumber
	,CtgPenaltyTypeId
	,SeqNo
FROM src.SupplementPreCtgDeniedLinesEligibleToPenalty
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


