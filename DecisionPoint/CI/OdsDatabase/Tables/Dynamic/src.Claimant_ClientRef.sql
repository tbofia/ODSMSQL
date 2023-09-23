IF OBJECT_ID('src.Claimant_ClientRef', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Claimant_ClientRef
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              CmtIdNo INT NOT NULL,
              CmtSuffix VARCHAR(50) NULL,
              ClaimIdNo INT NULL,
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Claimant_ClientRef ADD 
        CONSTRAINT PK_Claimant_ClientRef PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CmtIdNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Claimant_ClientRef ON src.Claimant_ClientRef REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Claimant_ClientRef'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Claimant_ClientRef ON src.Claimant_ClientRef REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
