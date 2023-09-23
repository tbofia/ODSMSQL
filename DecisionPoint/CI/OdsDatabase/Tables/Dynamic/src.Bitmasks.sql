IF OBJECT_ID('src.Bitmasks', 'U') IS NULL
    BEGIN

        CREATE TABLE src.Bitmasks
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              TableProgramUsed VARCHAR(50) NOT NULL ,
              AttributeUsed VARCHAR(50) NOT NULL ,
              Decimal BIGINT NOT NULL ,
              ConstantName VARCHAR(50) NULL ,
              Bit VARCHAR(50) NULL ,
              Hex VARCHAR(20) NULL ,
              Description VARCHAR(250) NULL 
              
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Bitmasks ADD 
        CONSTRAINT PK_Bitmasks PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, TableProgramUsed, AttributeUsed, Decimal) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Bitmasks ON src.Bitmasks REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Bitmasks'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Bitmasks ON src.Bitmasks REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

