IF OBJECT_ID('src.rsn_Override', 'U') IS NULL
BEGIN
	CREATE TABLE src.rsn_Override (
		OdsPostingGroupAuditId INT NOT NULL
		,OdsCustomerId INT NOT NULL
		,OdsCreateDate DATETIME2(7) NOT NULL
		,OdsSnapshotDate DATETIME2(7) NOT NULL
		,OdsRowIsCurrent BIT NOT NULL
		,OdsHashbytesValue VARBINARY(8000) NULL
		,DmlOperation CHAR(1) NOT NULL
		,ReasonNumber INT NOT NULL
		,ShortDesc VARCHAR(50) NULL
		,LongDesc VARCHAR(max) NULL
		,CategoryIdNo SMALLINT NULL
		,ClientSpec SMALLINT NULL
		,COAIndex SMALLINT NULL
		,NJPenaltyPct DECIMAL(9, 6) NULL
		,NetworkID INT NULL
		,SpecialProcessing BIT NULL
		) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

	ALTER TABLE src.rsn_Override ADD CONSTRAINT PK_rsn_Override PRIMARY KEY CLUSTERED (
		OdsPostingGroupAuditId
		,OdsCustomerId
		,ReasonNumber
		)
		WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_rsn_Override ON src.rsn_Override REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_rsn_Override'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_rsn_Override ON src.rsn_Override REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
