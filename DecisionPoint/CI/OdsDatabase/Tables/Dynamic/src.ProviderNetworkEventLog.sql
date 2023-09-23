IF OBJECT_ID('src.ProviderNetworkEventLog', 'U') IS NULL
BEGIN
CREATE TABLE src.ProviderNetworkEventLog(
	OdsPostingGroupAuditId int NOT NULL,
	OdsCustomerId int NOT NULL,
	OdsCreateDate datetime2(7) NOT NULL,
	OdsSnapshotDate datetime2(7) NOT NULL,
	OdsRowIsCurrent bit NOT NULL,
	OdsHashbytesValue varbinary(8000) NULL,
	DmlOperation char(1) NOT NULL,
	IDField int NOT NULL,
	LogDate datetime NULL,
	EventId int NULL,
	ClaimIdNo int NULL,
	BillIdNo int NULL,
	UserId int NULL,
	NetworkId int NULL,
	FileName varchar(255) NULL,
	ExtraText varchar(1000) NULL,
	ProcessInfo smallint NULL,
	TieredTypeID smallint NULL,
	TierNumber smallint NULL
		) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

	ALTER TABLE src.ProviderNetworkEventLog 
	ADD CONSTRAINT PK_ProviderNetworkEventLog
	PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId,OdsCustomerId,IDField)
		WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_ProviderNetworkEventLog ON src.ProviderNetworkEventLog REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_ProviderNetworkEventLog'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_ProviderNetworkEventLog ON src.ProviderNetworkEventLog REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
