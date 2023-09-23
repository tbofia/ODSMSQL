IF OBJECT_ID('src.AnalysisRuleThreshold', 'U') IS NULL
    BEGIN
        CREATE TABLE src.AnalysisRuleThreshold
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  AnalysisRuleThresholdId int NOT NULL,
	          AnalysisRuleId int NULL,
	          ThresholdKey varchar(50) NULL,
	          ThresholdValue varchar(100) NULL,
	          CreateDate datetimeoffset(7) NULL,
	          LastChangedOn datetimeoffset(7) NULL

            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.AnalysisRuleThreshold ADD 
        CONSTRAINT PK_AnalysisRuleThreshold PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,AnalysisRuleThresholdId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);
		
		ALTER INDEX PK_AnalysisRuleThreshold ON src.AnalysisRuleThreshold REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_AnalysisRuleThreshold'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_AnalysisRuleThreshold ON src.AnalysisRuleThreshold REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

