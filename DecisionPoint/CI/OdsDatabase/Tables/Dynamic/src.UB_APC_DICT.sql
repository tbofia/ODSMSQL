IF OBJECT_ID('src.Ub_Apc_Dict', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Ub_Apc_Dict
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              StartDate DATETIME NOT NULL ,
              EndDate DATETIME NULL ,
              APC VARCHAR(5) NOT NULL ,
              Description VARCHAR(255) NULL
              
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Ub_Apc_Dict ADD 
        CONSTRAINT PK_Ub_Apc_Dict PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, APC, StartDate) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Ub_Apc_Dict ON src.Ub_Apc_Dict REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Ub_Apc_Dict'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Ub_Apc_Dict ON src.Ub_Apc_Dict REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
