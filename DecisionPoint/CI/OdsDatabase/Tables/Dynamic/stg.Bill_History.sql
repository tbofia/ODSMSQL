IF OBJECT_ID('stg.Bill_History', 'U') IS NOT NULL
DROP TABLE stg.Bill_History
BEGIN
	CREATE TABLE stg.Bill_History (
		BillIdNo INT NULL
		,SeqNo INT NULL
		,DateCommitted DATETIME NULL
		,AmtCommitted MONEY NULL
		,UserId VARCHAR(15) NULL
		,AmtCoPay MONEY NULL
		,AmtDeductible MONEY NULL
		,Flags INT NULL
		,AmtSalesTax MONEY NULL
		,AmtOtherTax MONEY NULL
		,DeductibleOverride BIT NULL
		,PricingState VARCHAR(2) NULL
		,ApportionmentPercentage DECIMAL(5,2) NULL
		,FloridaDeductibleRuleEligible BIT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
