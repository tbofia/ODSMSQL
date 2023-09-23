IF OBJECT_ID('src.Vpn', 'U') IS NULL
BEGIN
	CREATE TABLE src.Vpn (
		OdsPostingGroupAuditId INT NOT NULL
		,OdsCustomerId INT NOT NULL
		,OdsCreateDate DATETIME2(7) NOT NULL
		,OdsSnapshotDate DATETIME2(7) NOT NULL
		,OdsRowIsCurrent BIT NOT NULL
		,OdsHashbytesValue VARBINARY(8000) NULL
		,DmlOperation CHAR(1) NOT NULL
		,VpnId SMALLINT NOT NULL
		,NetworkName VARCHAR(50) NULL
		,PendAndSend BIT NULL
		,BypassMatching BIT NULL
		,AllowsResends BIT NULL
		,OdsEligible BIT NULL
		) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

	ALTER TABLE src.Vpn ADD CONSTRAINT PK_Vpn PRIMARY KEY CLUSTERED (
		OdsPostingGroupAuditId
		,OdsCustomerId
		,VpnId
		)
		WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_Vpn ON src.Vpn REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Vpn'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Vpn ON src.Vpn REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
