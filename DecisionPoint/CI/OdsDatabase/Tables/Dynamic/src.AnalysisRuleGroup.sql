IF OBJECT_ID('src.AnalysisRuleGroup', 'U') IS NULL
    BEGIN
        CREATE TABLE src.AnalysisRuleGroup
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  AnalysisRuleGroupId int NOT NULL,
	          AnalysisRuleId int NULL,
	          AnalysisGroupId int NULL

            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.AnalysisRuleGroup ADD 
        CONSTRAINT PK_AnalysisRuleGroup PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,AnalysisRuleGroupId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_AnalysisRuleGroup ON src.AnalysisRuleGroup REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_AnalysisRuleGroup'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_AnalysisRuleGroup ON src.AnalysisRuleGroup REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

