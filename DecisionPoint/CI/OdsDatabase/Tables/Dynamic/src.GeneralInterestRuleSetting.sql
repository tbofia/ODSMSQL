IF OBJECT_ID('src.GeneralInterestRuleSetting', 'U') IS NULL
    BEGIN
        CREATE TABLE src.GeneralInterestRuleSetting
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              GeneralInterestRuleBaseTypeId TINYINT NOT NULL               
            )
        ON  DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.GeneralInterestRuleSetting ADD 
        CONSTRAINT PK_GeneralInterestRuleSetting PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, GeneralInterestRuleBaseTypeId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);
		
		ALTER INDEX PK_GeneralInterestRuleSetting ON src.GeneralInterestRuleSetting REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END;
GO
