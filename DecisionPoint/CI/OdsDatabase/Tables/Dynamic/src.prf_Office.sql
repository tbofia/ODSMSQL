IF OBJECT_ID('src.prf_Office', 'U') IS NULL
    BEGIN
        CREATE TABLE src.prf_Office
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              CompanyId INT NULL ,
              OfficeId INT NOT NULL ,
              OfcNo VARCHAR(4) NULL ,
              OfcName VARCHAR(40) NULL ,
              OfcAddr1 VARCHAR(30) NULL ,
              OfcAddr2 VARCHAR(30) NULL ,
              OfcCity VARCHAR(30) NULL ,
              OfcState VARCHAR(2) NULL ,
              OfcZip VARCHAR(12) NULL ,
              OfcPhone VARCHAR(20) NULL ,
              OfcDefault SMALLINT NULL ,
              OfcClaimMask VARCHAR(50) NULL ,
              OfcTinMask VARCHAR(50) NULL ,
              Version SMALLINT NULL ,
              OfcEdits INT NULL ,
              OfcCOAEnabled SMALLINT NULL ,
              CTGEnabled SMALLINT NULL ,
              LastChangedOn DATETIME NULL ,
              AllowMultiCoverage BIT NULL
            )
        ON  DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.prf_Office ADD 
        CONSTRAINT PK_prf_Office PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, OfficeId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_prf_Office ON src.prf_Office REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END;
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.prf_Office')
                        AND NAME = 'AllowMultiCoverage' )
    BEGIN
        ALTER TABLE src.prf_Office ADD AllowMultiCoverage BIT NULL;
    END;
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_prf_Office'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_prf_Office ON src.prf_Office REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
