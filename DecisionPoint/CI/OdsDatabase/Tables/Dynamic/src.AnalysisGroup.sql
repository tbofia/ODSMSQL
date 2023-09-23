IF OBJECT_ID('src.AnalysisGroup', 'U') IS NULL
    BEGIN
        CREATE TABLE src.AnalysisGroup
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  AnalysisGroupId int NOT NULL,
	          GroupName varchar(200) NULL
	          
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.AnalysisGroup ADD 
        CONSTRAINT PK_AnalysisGroup PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,AnalysisGroupId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_AnalysisGroup ON src.AnalysisGroup REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_AnalysisGroup'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_AnalysisGroup ON src.AnalysisGroup REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

