IF OBJECT_ID('src.DiagnosisCodeGroup', 'U') IS NULL
    BEGIN

        CREATE TABLE src.DiagnosisCodeGroup
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,  
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              DiagnosisCode VARCHAR(8) NOT NULL ,
              StartDate DATETIME NOT NULL ,
              EndDate DATETIME NULL ,
              MajorCategory VARCHAR(500) NULL ,
              MinorCategory VARCHAR(500) NULL 
            
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.DiagnosisCodeGroup ADD 
        CONSTRAINT PK_DiagnosisCodeGroup PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, DiagnosisCode, StartDate) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_DiagnosisCodeGroup ON src.DiagnosisCodeGroup REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_DiagnosisCodeGroup'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_DiagnosisCodeGroup ON src.DiagnosisCodeGroup REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
