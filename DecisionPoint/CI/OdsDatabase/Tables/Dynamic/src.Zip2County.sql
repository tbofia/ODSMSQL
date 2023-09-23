IF OBJECT_ID('src.Zip2County', 'U') IS NULL
BEGIN
    CREATE TABLE src.Zip2County
        (
            OdsPostingGroupAuditId INT NOT NULL ,
            OdsCustomerId INT NOT NULL ,
            OdsCreateDate DATETIME2(7) NOT NULL ,
            OdsSnapshotDate DATETIME2(7) NOT NULL ,
            OdsRowIsCurrent BIT NOT NULL ,
            OdsHashbytesValue VARBINARY(8000) NULL,
            DmlOperation CHAR(1) NOT NULL ,
            Zip VARCHAR(5) NOT NULL ,
            County VARCHAR(50) NULL ,
            State VARCHAR(2) NULL 
            
        )ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.Zip2County ADD 
    CONSTRAINT PK_Zip2County PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Zip) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_Zip2County ON src.Zip2County REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Zip2County'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Zip2County ON src.Zip2County REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
