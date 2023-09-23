IF OBJECT_ID('src.BillsProviderNetwork', 'U') IS NULL
BEGIN
	CREATE TABLE src.BillsProviderNetwork (
		OdsPostingGroupAuditId INT NOT NULL
		,OdsCustomerId INT NOT NULL
		,OdsCreateDate DATETIME2(7) NOT NULL
		,OdsSnapshotDate DATETIME2(7) NOT NULL
		,OdsRowIsCurrent BIT NOT NULL
		,OdsHashbytesValue VARBINARY(8000) NULL
		,DmlOperation CHAR(1) NOT NULL
		,BillIdNo INT NOT NULL
		,NetworkId INT NULL
		,NetworkName VARCHAR(50) NULL
		) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

	ALTER TABLE src.BillsProviderNetwork ADD CONSTRAINT PK_BillsProviderNetwork PRIMARY KEY CLUSTERED (
		OdsPostingGroupAuditId
		,OdsCustomerId
		,BillIdNo
		)
		WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_BillsProviderNetwork ON src.BillsProviderNetwork REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
Go

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_BillsProviderNetwork'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_BillsProviderNetwork ON src.BillsProviderNetwork REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
