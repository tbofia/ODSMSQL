IF OBJECT_ID('src.ProcedureCodeGroup', 'U') IS NULL
    BEGIN
        CREATE TABLE src.ProcedureCodeGroup
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              ProcedureCode VARCHAR(7) NOT NULL ,
              MajorCategory VARCHAR(500) NULL ,
              MinorCategory VARCHAR(500) NULL 
              
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.ProcedureCodeGroup ADD 
        CONSTRAINT PK_ProcedureCodeGroup PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProcedureCode) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_ProcedureCodeGroup ON src.ProcedureCodeGroup REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_ProcedureCodeGroup'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_ProcedureCodeGroup ON src.ProcedureCodeGroup REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
