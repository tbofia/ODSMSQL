IF OBJECT_ID('src.Vpn_Billing_History', 'U') IS NULL
BEGIN

CREATE TABLE src.Vpn_Billing_History(
	OdsPostingGroupAuditId int NOT NULL,
	OdsCustomerId int NOT NULL,
	OdsCreateDate datetime2(7) NOT NULL,
	OdsSnapshotDate datetime2(7) NOT NULL,
	OdsRowIsCurrent bit NOT NULL,
	OdsHashbytesValue varbinary(8000) NULL,
	DmlOperation char(1) NOT NULL,
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
	VpnBillingCategoryCode char(1) NULL
		) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

	ALTER TABLE src.Vpn_Billing_History 
	ADD CONSTRAINT PK_Vpn_Billing_History 
	PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId,OdsCustomerId,TransactionID,Period)
		WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_Vpn_Billing_History ON src.Vpn_Billing_History REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Vpn_Billing_History'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Vpn_Billing_History ON src.Vpn_Billing_History REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
