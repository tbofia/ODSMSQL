IF OBJECT_ID('src.CMT_HDR', 'U') IS NULL
    BEGIN
        CREATE TABLE src.CMT_HDR
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,    
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              CMT_HDR_IDNo INT NOT NULL ,
              CmtIDNo INT NULL ,
              PvdIDNo INT NULL ,
              LastChangedOn DATETIME NULL 
          
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.CMT_HDR ADD 
        CONSTRAINT PK_CMT_HDR PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CMT_HDR_IDNo)WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_CMT_HDR ON src.CMT_HDR REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_CMT_HDR'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_CMT_HDR ON src.CMT_HDR REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
