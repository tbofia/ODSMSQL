IF OBJECT_ID('src.Claims_ClientRef', 'U') IS NULL
BEGIN
    CREATE TABLE src.Claims_ClientRef
        (
		OdsPostingGroupAuditId INT NOT NULL ,
		OdsCustomerId INT NOT NULL ,
		OdsCreateDate DATETIME2(7) NOT NULL ,
		OdsSnapshotDate DATETIME2(7) NOT NULL ,
		OdsRowIsCurrent BIT NOT NULL ,
		OdsHashbytesValue VARBINARY(8000) NULL ,
		DmlOperation CHAR(1) NOT NULL ,
		ClaimIdNo INT NOT NULL,
		ClientRefId VARCHAR(50) NULL
		)ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (
             DATA_COMPRESSION = PAGE);

    ALTER TABLE src.Claims_ClientRef ADD 
    CONSTRAINT PK_Claims_ClientRef PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimIdNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_Claims_ClientRef ON src.Claims_ClientRef REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Claims_ClientRef'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Claims_ClientRef ON src.Claims_ClientRef REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
