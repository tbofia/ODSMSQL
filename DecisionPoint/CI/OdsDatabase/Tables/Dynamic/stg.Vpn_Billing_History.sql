IF OBJECT_ID('stg.Vpn_Billing_History', 'U') IS NOT NULL
DROP TABLE stg.Vpn_Billing_History
BEGIN
CREATE TABLE stg.Vpn_Billing_History(
	Customer varchar(50) NULL,
	TransactionID bigint NOT NULL,
	Period datetime NOT NULL,
	ActivityFlag varchar(1) NULL,
	BillableFlag varchar(1) NULL,
	Void varchar(4) NULL,
	CreditType varchar(10) NULL,
	Network varchar(50) NULL,
	BillIdNo int NULL,
	Line_No smallint NULL,
	TransactionDate datetime NULL,
	RepriceDate datetime NULL,
	ClaimNo varchar(50) NULL,
	ProviderCharges money NULL,
	DPAllowed money NULL,
	VPNAllowed money NULL,
	Savings money NULL,
	Credits money NULL,
	NetSavings money NULL,
	SOJ varchar(2) NULL,
	seqno int NULL,
	CompanyCode varchar(10) NULL,
	VpnId smallint NULL,
	ProcessFlag smallint NULL,
	SK int NULL,
	DATABASE_NAME varchar(100) NULL,
	SubmittedToFinance bit NULL,
	IsInitialLoad bit NULL,
	VpnBillingCategoryCode char(1) NULL,
	DmlOperation char(1) NOT NULL
		)
END
GO
