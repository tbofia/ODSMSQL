IF OBJECT_ID('src.RPT_RsnCategories', 'U') IS NULL
    BEGIN
        CREATE TABLE src.RPT_RsnCategories
            (
			OdsPostingGroupAuditId INT NOT NULL ,
			OdsCustomerId INT NOT NULL ,
			OdsCreateDate DATETIME2(7) NOT NULL ,
			OdsSnapshotDate DATETIME2(7) NOT NULL ,
			OdsRowIsCurrent BIT NOT NULL ,
			OdsHashbytesValue VARBINARY(8000) NULL ,
			DmlOperation CHAR(1) NOT NULL ,
			CategoryIdNo SMALLINT NOT NULL,
			CatDesc VARCHAR(50) NULL,
			Priority SMALLINT NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.RPT_RsnCategories ADD 
        CONSTRAINT PK_RPT_RsnCategories PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CategoryIdNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_RPT_RsnCategories ON src.RPT_RsnCategories REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_RPT_RsnCategories'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_RPT_RsnCategories ON src.RPT_RsnCategories REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
