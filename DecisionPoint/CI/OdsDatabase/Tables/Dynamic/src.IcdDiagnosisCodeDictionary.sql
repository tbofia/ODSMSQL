IF OBJECT_ID('src.IcdDiagnosisCodeDictionary', 'U') IS NULL
    BEGIN
        CREATE TABLE src.IcdDiagnosisCodeDictionary
            (
			 OdsPostingGroupAuditId INT NOT NULL ,
			 OdsCustomerId INT NOT NULL ,              
			 OdsCreateDate DATETIME2(7) NOT NULL ,
			 OdsSnapshotDate DATETIME2(7) NOT NULL ,
			 OdsRowIsCurrent BIT NOT NULL ,
			 OdsHashbytesValue VARBINARY(8000) NULL ,
			 DmlOperation CHAR(1) NOT NULL ,
			 DiagnosisCode VARCHAR(8) NOT NULL,
			 IcdVersion TINYINT NOT NULL,
			 StartDate DATETIME2(7) NOT NULL,
			 EndDate DATETIME2(7) NULL,
			 NonSpecific BIT NULL,
			 Traumatic BIT NULL,
			 Duration TINYINT NULL,
			 [Description] VARCHAR(max) NULL,
			 DiagnosisFamilyId TINYINT NULL,
			 DiagnosisSeverityId TINYINT NULL,
			 LateralityId TINYINT NULL,
			 TotalCharactersRequired TINYINT NULL,
			 PlaceholderRequired BIT NULL,
			 Flags SMALLINT NULL,
			 AdditionalDigits BIT NULL,
			 Colossus SMALLINT NULL,
			 InjuryNatureId TINYINT NULL,
			 EncounterSubcategoryId TINYINT NULL
           )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.IcdDiagnosisCodeDictionary ADD 
        CONSTRAINT PK_IcdDiagnosisCodeDictionary PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, DiagnosisCode, IcdVersion, StartDate) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_IcdDiagnosisCodeDictionary ON src.IcdDiagnosisCodeDictionary REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.IcdDiagnosisCodeDictionary')
                        AND NAME = 'EncounterSubcategoryId' )
BEGIN
    ALTER TABLE src.IcdDiagnosisCodeDictionary ADD EncounterSubcategoryId TINYINT NULL
END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_IcdDiagnosisCodeDictionary'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_IcdDiagnosisCodeDictionary ON src.IcdDiagnosisCodeDictionary REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO




