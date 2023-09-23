IF OBJECT_ID('src.CustomBillStatuses', 'U') IS NULL
    BEGIN
        CREATE TABLE src.CustomBillStatuses
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              StatusId INT  NOT NULL,
              StatusName VARCHAR(50) NULL,
              StatusDescription VARCHAR(300) NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.CustomBillStatuses ADD 
        CONSTRAINT PK_CustomBillStatuses PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, StatusId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_CustomBillStatuses ON src.CustomBillStatuses REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_CustomBillStatuses'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_CustomBillStatuses ON src.CustomBillStatuses REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

