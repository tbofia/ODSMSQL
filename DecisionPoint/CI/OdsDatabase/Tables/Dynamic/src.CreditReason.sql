IF OBJECT_ID('src.CreditReason', 'U') IS NULL
BEGIN
	CREATE TABLE src.CreditReason (
		OdsPostingGroupAuditId INT NOT NULL
		,OdsCustomerId INT NOT NULL
		,OdsCreateDate DATETIME2(7) NOT NULL
		,OdsSnapshotDate DATETIME2(7) NOT NULL
		,OdsRowIsCurrent BIT NOT NULL
		,OdsHashbytesValue VARBINARY(8000) NULL
		,DmlOperation CHAR(1) NOT NULL
		,CreditReasonId INT NOT NULL
		,CreditReasonDesc VARCHAR(100) NULL
		,IsVisible BIT NULL 
		) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

	ALTER TABLE src.CreditReason ADD CONSTRAINT PK_CreditReason PRIMARY KEY CLUSTERED (
		OdsPostingGroupAuditId
		,OdsCustomerId
		,CreditReasonId
		)
		WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_CreditReason ON src.CreditReason REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
Go

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_CreditReason'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_CreditReason ON src.CreditReason REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
