
IF OBJECT_ID('src.MedicareStatusIndicatorRule', 'U') IS NULL
    BEGIN
        CREATE TABLE src.MedicareStatusIndicatorRule
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              MedicareStatusIndicatorRuleId INT NOT NULL ,
              MedicareStatusIndicatorRuleName VARCHAR(50) NULL ,
              StatusIndicator VARCHAR(500) NULL ,
			  StartDate DATETIME2(7) NULL,
			  EndDate DATETIME2(7) NULL,
			  Endnote INT NULL,
	          EditActionId TINYINT NULL,
	          Comments VARCHAR(1000) NULL,
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.MedicareStatusIndicatorRule ADD 
        CONSTRAINT PK_MedicareStatusIndicatorRule PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, MedicareStatusIndicatorRuleId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_MedicareStatusIndicatorRule ON src.MedicareStatusIndicatorRule REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO


