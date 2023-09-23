IF OBJECT_ID('src.CustomerBillExclusion', 'U') IS NULL
BEGIN
    CREATE TABLE src.CustomerBillExclusion
        (
            OdsPostingGroupAuditId INT NOT NULL ,
            OdsCustomerId INT NOT NULL ,
            OdsCreateDate DATETIME2(7) NOT NULL ,
			OdsSnapshotDate DATETIME2(7) NOT NULL ,
			OdsRowIsCurrent BIT NOT NULL ,
			OdsHashbytesValue VARBINARY(8000) NULL,
			DmlOperation CHAR(1) NOT NULL ,
            BillIdNo int NOT NULL,
	        Customer nvarchar(50) NOT NULL,
	        ReportID tinyint NOT NULL,
			CreateDate datetime  NULL
        ) ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.CustomerBillExclusion ADD 
    CONSTRAINT PK_CustomerBillExclusion PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIdNo,Customer,ReportID) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_CustomerBillExclusion ON src.CustomerBillExclusion REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_CustomerBillExclusion'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_CustomerBillExclusion ON src.CustomerBillExclusion REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

