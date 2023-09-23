IF OBJECT_ID('src.CMT_ICD9', 'U') IS NULL
    BEGIN
        CREATE TABLE src.CMT_ICD9
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,  
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              BillIDNo INT NOT NULL ,
              SeqNo SMALLINT NOT NULL ,
              ICD9 VARCHAR(7) NULL ,
              IcdVersion TINYINT NULL 
            
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.CMT_ICD9 ADD 
        CONSTRAINT PK_CMT_ICD9 PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIDNo, SeqNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_CMT_ICD9 ON src.CMT_ICD9 REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_CMT_ICD9'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_CMT_ICD9 ON src.CMT_ICD9 REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
