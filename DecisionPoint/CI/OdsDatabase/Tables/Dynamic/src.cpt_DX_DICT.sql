IF OBJECT_ID('src.cpt_DX_DICT', 'U') IS NULL
    BEGIN
        CREATE TABLE src.cpt_DX_DICT
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL , 
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              ICD9 VARCHAR(6) NOT NULL ,
              StartDate DATETIME NOT NULL ,
              EndDate DATETIME NULL ,
              Flags SMALLINT NULL ,
              NonSpecific VARCHAR(1) NULL ,
              AdditionalDigits VARCHAR(1) NULL ,
              Traumatic VARCHAR(1) NULL ,
              DX_DESC VARCHAR(MAX) NULL ,
              Duration SMALLINT NULL ,
              Colossus SMALLINT NULL ,
              DiagnosisFamilyId TINYINT NULL
             
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.cpt_DX_DICT ADD 
        CONSTRAINT PK_cpt_DX_DICT PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ICD9, StartDate) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_cpt_DX_DICT ON src.cpt_DX_DICT REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_cpt_DX_DICT'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_cpt_DX_DICT ON src.cpt_DX_DICT REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
