IF OBJECT_ID('src.ICD10ProcedureCode', 'U') IS NULL
    BEGIN
        CREATE TABLE src.ICD10ProcedureCode
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              ICDProcedureCode VARCHAR(7) NOT NULL ,
              StartDate DATETIME NOT NULL ,
              EndDate DATETIME NULL ,
              Description VARCHAR(300) NULL ,
              PASGrpNo SMALLINT NULL 
              
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.ICD10ProcedureCode ADD 
        CONSTRAINT PK_ICD10ProcedureCode PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ICDProcedureCode, StartDate) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_ICD10ProcedureCode ON src.ICD10ProcedureCode REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_ICD10ProcedureCode'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_ICD10ProcedureCode ON src.ICD10ProcedureCode REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
