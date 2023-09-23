IF OBJECT_ID('src.UB_BillType', 'U') IS NULL
    BEGIN
        CREATE TABLE src.UB_BillType
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              TOB VARCHAR(4) NOT NULL ,
              Description VARCHAR(MAX) NULL ,
              Flag INT NULL ,
              UB_BillTypeID INT NULL 
              
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.UB_BillType ADD 
        CONSTRAINT PK_UB_BillType PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, TOB) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_UB_BillType ON src.UB_BillType REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_UB_BillType'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_UB_BillType ON src.UB_BillType REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
