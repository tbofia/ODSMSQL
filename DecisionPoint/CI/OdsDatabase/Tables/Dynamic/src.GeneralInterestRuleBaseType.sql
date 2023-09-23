IF OBJECT_ID('src.GeneralInterestRuleBaseType', 'U') IS NULL
BEGIN
    CREATE TABLE src.GeneralInterestRuleBaseType
    (
        OdsPostingGroupAuditId INT NOT NULL,
        OdsCustomerId INT NOT NULL,
        OdsCreateDate DATETIME2(7) NOT NULL,
        OdsSnapshotDate DATETIME2(7) NOT NULL,
        OdsRowIsCurrent BIT NOT NULL,
        OdsHashbytesValue VARBINARY(8000) NULL,
        DmlOperation CHAR(1) NOT NULL,
        GeneralInterestRuleBaseTypeId TINYINT NOT NULL,
        GeneralInterestRuleBaseTypeName VARCHAR(50) NULL
    ) ON DP_Ods_PartitionScheme (OdsCustomerId)
    WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.GeneralInterestRuleBaseType
    ADD CONSTRAINT PK_GeneralInterestRuleBaseType
        PRIMARY KEY CLUSTERED (
                                  OdsPostingGroupAuditId,
                                  OdsCustomerId,
                                  GeneralInterestRuleBaseTypeId
                              )
        WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

    ALTER INDEX PK_GeneralInterestRuleBaseType
    ON src.GeneralInterestRuleBaseType
    REBUILD
    WITH (STATISTICS_INCREMENTAL = ON);
END;

GO
