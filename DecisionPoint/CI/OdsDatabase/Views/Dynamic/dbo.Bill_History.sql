IF OBJECT_ID('dbo.Bill_History', 'V') IS NOT NULL
    DROP VIEW dbo.Bill_History;
GO

CREATE VIEW dbo.Bill_History
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
	,SeqNo
	,DateCommitted
	,AmtCommitted
	,UserId
	,AmtCoPay
	,AmtDeductible
	,Flags
	,AmtSalesTax
	,AmtOtherTax
	,DeductibleOverride
	,PricingState
	,ApportionmentPercentage
	,FloridaDeductibleRuleEligible
FROM src.Bill_History
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


