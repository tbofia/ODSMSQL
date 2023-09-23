IF OBJECT_ID('src.ZipCode', 'U') IS NULL
    BEGIN
        CREATE TABLE src.ZipCode
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              ZipCode VARCHAR(5) NOT NULL ,
              PrimaryRecord BIT NULL ,
              STATE VARCHAR(2) NULL ,
              City VARCHAR(30) NULL ,
              CityAlias VARCHAR(30) NOT NULL ,
              County VARCHAR(30) NULL ,
              Cbsa VARCHAR(5) NULL ,
              CbsaType VARCHAR(5) NULL ,
              ZipCodeRegionId TINYINT NULL
            )
        ON  DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.ZipCode ADD CONSTRAINT PK_ZipCode PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ZipCode, CityAlias)
        WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_ZipCode ON src.ZipCode REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END;
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.ZipCode')
                        AND NAME = 'ZipCodeRegionId' )
    BEGIN
        ALTER TABLE src.ZipCode ADD ZipCodeRegionId TINYINT NULL;
    END;
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_ZipCode'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_ZipCode ON src.ZipCode REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
