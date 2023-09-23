IF OBJECT_ID('src.cpt_PRC_DICT', 'U') IS NULL
    BEGIN
        CREATE TABLE src.cpt_PRC_DICT
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,  
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              PRC_CD VARCHAR(7) NOT NULL ,
              StartDate DATETIME NOT NULL ,
              EndDate DATETIME NULL ,
              PRC_DESC VARCHAR(MAX) NULL ,
              Flags INT NULL ,
              Vague VARCHAR(1) NULL ,
              PerVisit SMALLINT NULL ,
              PerClaimant SMALLINT NULL ,
              PerProvider SMALLINT NULL ,
              BodyFlags INT NULL ,
              Colossus SMALLINT NULL ,
              CMS_Status VARCHAR(1) NULL ,
              DrugFlag SMALLINT NULL ,
              CurativeFlag SMALLINT NULL ,
              ExclPolicyLimit SMALLINT NULL ,
              SpecNetFlag SMALLINT NULL 
            
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.cpt_PRC_DICT ADD 
        CONSTRAINT PK_cpt_PRC_DICT PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PRC_CD, StartDate) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_cpt_PRC_DICT ON src.cpt_PRC_DICT REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_cpt_PRC_DICT'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_cpt_PRC_DICT ON src.cpt_PRC_DICT REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
