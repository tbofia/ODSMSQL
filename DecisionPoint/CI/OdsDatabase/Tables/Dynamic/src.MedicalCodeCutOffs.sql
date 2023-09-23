IF OBJECT_ID('src.MedicalCodeCutOffs', 'U') IS NULL
    BEGIN
        CREATE TABLE src.MedicalCodeCutOffs
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              CodeTypeID INT NOT NULL,
              CodeType VARCHAR(50) NULL,
              Code VARCHAR(50) NOT NULL,
              FormType VARCHAR(10) NOT NULL,
              MaxChargedPerUnit FLOAT NULL,
              MaxUnitsPerEncounter FLOAT NULL          

            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.MedicalCodeCutOffs ADD 
        CONSTRAINT PK_MedicalCodeCutOffs PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CodeTypeID, Code, FormType) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_MedicalCodeCutOffs ON src.MedicalCodeCutOffs REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_MedicalCodeCutOffs'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_MedicalCodeCutOffs ON src.MedicalCodeCutOffs REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
