IF OBJECT_ID('src.CMT_DX', 'U') IS NULL
    BEGIN
        CREATE TABLE src.CMT_DX
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL , 
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              BillIDNo INT NOT NULL ,
              DX VARCHAR(8) NOT NULL ,
              SeqNum SMALLINT NULL ,
              POA VARCHAR(1) NULL ,
              IcdVersion TINYINT NOT NULL
             
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.CMT_DX ADD 
        CONSTRAINT PK_CMT_DX PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIDNo, DX, IcdVersion) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_CMT_DX ON src.CMT_DX REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_CMT_DX'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_CMT_DX ON src.CMT_DX REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
