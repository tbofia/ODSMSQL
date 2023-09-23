IF OBJECT_ID('src.ClaimantProviderSummaryEvaluation', 'U') IS NULL
    BEGIN
        CREATE TABLE src.ClaimantProviderSummaryEvaluation
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              ClaimantProviderSummaryEvaluationId INT NOT NULL ,
              ClaimantHeaderId INT NULL ,
              EvaluatedAmount DECIMAL(19, 4) NULL ,
              MinimumEvaluatedAmount DECIMAL(19, 4) NULL ,
              MaximumEvaluatedAmount DECIMAL(19, 4) NULL ,
              Comments VARCHAR(255) NULL
            )
        ON  DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.ClaimantProviderSummaryEvaluation ADD 
        CONSTRAINT PK_ClaimantProviderSummaryEvaluation PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimantProviderSummaryEvaluationId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_ClaimantProviderSummaryEvaluation ON src.ClaimantProviderSummaryEvaluation REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END;
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_ClaimantProviderSummaryEvaluation'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_ClaimantProviderSummaryEvaluation ON src.ClaimantProviderSummaryEvaluation REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
