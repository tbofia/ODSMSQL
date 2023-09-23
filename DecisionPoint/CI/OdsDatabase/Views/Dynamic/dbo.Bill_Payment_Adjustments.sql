IF OBJECT_ID('dbo.Bill_Payment_Adjustments', 'V') IS NOT NULL
    DROP VIEW dbo.Bill_Payment_Adjustments;
GO

CREATE VIEW dbo.Bill_Payment_Adjustments
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Bill_Payment_Adjustment_ID
	,BillIDNo
	,SeqNo
	,InterestFlags
	,DateInterestStarts
	,DateInterestEnds
	,InterestAdditionalInfoReceived
	,Interest
	,Comments
FROM src.Bill_Payment_Adjustments
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


