IF OBJECT_ID('src.BillExclusionLookUpTable', 'U') IS NULL
BEGIN
    CREATE TABLE src.BillExclusionLookUpTable
        (
            OdsPostingGroupAuditId INT NOT NULL ,
            OdsCustomerId INT NOT NULL ,
            OdsCreateDate DATETIME2(7) NOT NULL ,
			OdsSnapshotDate DATETIME2(7) NOT NULL ,
			OdsRowIsCurrent BIT NOT NULL ,
			OdsHashbytesValue VARBINARY(8000) NULL,
			DmlOperation CHAR(1) NOT NULL ,
            ReportID tinyint NOT NULL,
	        ReportName nvarchar(100) NULL
        ) ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.BillExclusionLookUpTable ADD 
    CONSTRAINT PK_BillExclusionLookUpTable PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ReportID) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_BillExclusionLookUpTable ON src.BillExclusionLookUpTable REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_BillExclusionLookUpTable'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_BillExclusionLookUpTable ON src.BillExclusionLookUpTable REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
