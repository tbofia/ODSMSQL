IF OBJECT_ID('src.Provider_ClientRef', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Provider_ClientRef
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              PvdIdNo INT NOT NULL,
              ClientRefId VARCHAR(50) NULL,
              ClientRefId2 VARCHAR(100) NULL,
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Provider_ClientRef ADD 
        CONSTRAINT PK_Provider_ClientRef PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PvdIdNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Provider_ClientRef ON src.Provider_ClientRef REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Provider_ClientRef'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Provider_ClientRef ON src.Provider_ClientRef REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

