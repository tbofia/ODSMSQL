IF OBJECT_ID('src.Icd10DiagnosisVersion', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Icd10DiagnosisVersion
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,              
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              DiagnosisCode VARCHAR(8) NOT NULL ,
              StartDate DATETIME NOT NULL ,
              EndDate DATETIME NULL ,
              NonSpecific BIT NULL ,
              Traumatic BIT NULL ,
              Duration SMALLINT NULL ,
              Description VARCHAR(MAX) NULL ,
              DiagnosisFamilyId TINYINT NULL ,
			  TotalCharactersRequired TINYINT NULL ,
			  PlaceholderRequired BIT NULL 

            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Icd10DiagnosisVersion ADD 
        CONSTRAINT PK_Icd10DiagnosisVersion PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, DiagnosisCode, StartDate) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Icd10DiagnosisVersion ON src.Icd10DiagnosisVersion REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Icd10DiagnosisVersion'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Icd10DiagnosisVersion ON src.Icd10DiagnosisVersion REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Icd10DiagnosisVersion')
						AND NAME = 'TotalCharactersRequired' )
	BEGIN
		ALTER TABLE src.Icd10DiagnosisVersion ADD TotalCharactersRequired TINYINT NULL ;
	END 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Icd10DiagnosisVersion')
						AND NAME = 'PlaceholderRequired' )
	BEGIN
		ALTER TABLE src.Icd10DiagnosisVersion ADD PlaceholderRequired BIT NULL ;
	END 
GO
