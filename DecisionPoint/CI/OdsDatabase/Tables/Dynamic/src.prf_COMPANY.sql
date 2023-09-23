IF OBJECT_ID('src.prf_COMPANY', 'U') IS NULL
    BEGIN
        CREATE TABLE src.prf_COMPANY
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              CompanyId INT NOT NULL ,
              CompanyName VARCHAR(50) NULL ,
              LastChangedOn DATETIME NULL 
              
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.prf_COMPANY ADD 
        CONSTRAINT PK_prf_COMPANY PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CompanyId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_prf_COMPANY ON src.prf_COMPANY REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_prf_COMPANY'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_prf_COMPANY ON src.prf_COMPANY REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
