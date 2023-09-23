IF OBJECT_ID('src.EvaluationSummary', 'U') IS NULL
BEGIN
    CREATE TABLE src.EvaluationSummary
    (
        OdsPostingGroupAuditId INT NOT NULL,
        OdsCustomerId INT NOT NULL,
        OdsCreateDate DATETIME2(7) NOT NULL,
        OdsSnapshotDate DATETIME2(7) NOT NULL,
        OdsRowIsCurrent BIT NOT NULL,
        OdsHashbytesValue VARBINARY(8000) NULL,
        DmlOperation CHAR(1) NOT NULL,
        DemandClaimantId INT NOT NULL,
        Details NVARCHAR(MAX) NULL,
        CreatedBy NVARCHAR(50) NULL,
        CreatedDate DATETIMEOFFSET(7) NULL,
        ModifiedBy NVARCHAR(50) NULL,
        ModifiedDate DATETIMEOFFSET(7) NULL
    ) ON DP_Ods_PartitionScheme (OdsCustomerId)
    WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.EvaluationSummary
    ADD CONSTRAINT PK_EvaluationSummary
        PRIMARY KEY CLUSTERED (
                                  OdsPostingGroupAuditId,
                                  OdsCustomerId,
                                  DemandClaimantId
                              )
        WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

    ALTER INDEX PK_EvaluationSummary
    ON src.EvaluationSummary
    REBUILD
    WITH (STATISTICS_INCREMENTAL = ON);
END;

GO
IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.EvaluationSummary')
						AND NAME = 'EvaluationSummaryTemplateVersionId' )
	BEGIN
		ALTER TABLE src.EvaluationSummary ADD EvaluationSummaryTemplateVersionId INT NULL ;
	END ; 
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1 
                FROM sys.stats
                WHERE name = 'PK_EvaluationSummary' 
                AND is_incremental = 1)  
BEGIN
ALTER INDEX PK_EvaluationSummary ON src.EvaluationSummary   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 

END ;
GO




