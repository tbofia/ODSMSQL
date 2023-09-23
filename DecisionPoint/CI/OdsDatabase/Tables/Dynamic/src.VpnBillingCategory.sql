IF OBJECT_ID('src.VpnBillingCategory', 'U') IS NULL
BEGIN
	CREATE TABLE src.VpnBillingCategory (
		OdsPostingGroupAuditId int NOT NULL,
		OdsCustomerId int NOT NULL,
		OdsCreateDate datetime2(7) NOT NULL,
		OdsSnapshotDate datetime2(7) NOT NULL,
		OdsRowIsCurrent bit NOT NULL,
		OdsHashbytesValue varbinary(8000) NULL,
		DmlOperation char(1) NOT NULL,
		VpnBillingCategoryCode char(1) NOT NULL,
		VpnBillingCategoryDescription varchar(30) NULL
		) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

	ALTER TABLE src.VpnBillingCategory 
	ADD CONSTRAINT PK_VpnBillingCategory 
	PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId,OdsCustomerId,VpnBillingCategoryCode)
		WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_VpnBillingCategory ON src.VpnBillingCategory REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_VpnBillingCategory'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_VpnBillingCategory ON src.VpnBillingCategory REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
