IF OBJECT_ID('src.BillsOverride', 'U') IS NULL
    BEGIN
        CREATE TABLE src.BillsOverride
            (
			OdsPostingGroupAuditId INT NOT NULL ,
			OdsCustomerId INT NOT NULL ,
			OdsCreateDate DATETIME2(7) NOT NULL ,
			OdsSnapshotDate DATETIME2(7) NOT NULL ,
			OdsRowIsCurrent BIT NOT NULL ,
			OdsHashbytesValue VARBINARY(8000) NULL ,
			DmlOperation CHAR(1) NOT NULL ,
			BillsOverrideID INT NOT NULL,
			BillIDNo INT NULL,
			LINE_NO SMALLINT NULL,
			UserId INT NULL,
			DateSaved DATETIME NULL,
			AmountBefore MONEY NULL,
			AmountAfter MONEY NULL,
			CodesOverrode VARCHAR(50) NULL,
			SeqNo INT NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.BillsOverride ADD 
        CONSTRAINT PK_BillsOverride PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillsOverrideID) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);
    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_BillsOverride'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_BillsOverride ON src.BillsOverride REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
