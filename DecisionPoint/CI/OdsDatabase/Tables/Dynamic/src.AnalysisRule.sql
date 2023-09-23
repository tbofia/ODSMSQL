IF OBJECT_ID('src.AnalysisRule', 'U') IS NULL
    BEGIN
        CREATE TABLE src.AnalysisRule
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              AnalysisRuleId INT NOT NULL ,
              Title VARCHAR(200) NULL ,
              AssemblyQualifiedName VARCHAR(200) NULL ,
              MethodToInvoke VARCHAR(50) NULL ,
              DisplayMessage NVARCHAR(200) NULL ,
              DisplayOrder INT NULL ,
              IsActive BIT NULL ,
              CreateDate DATETIMEOFFSET(7) NULL ,
              LastChangedOn DATETIMEOFFSET(7) NULL ,
              MessageToken NVARCHAR(200) NULL
            )
        ON  DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.AnalysisRule ADD 
        CONSTRAINT PK_AnalysisRule PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,AnalysisRuleId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_AnalysisRule ON src.AnalysisRule REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

IF EXISTS ( SELECT  1
            FROM    sys.columns c
                    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE   c.object_id = OBJECT_ID(N'src.AnalysisRule')
                    AND c.name = 'AssemblyQualifiedName'
                    AND c.max_length <> 200 )
    BEGIN
        ALTER TABLE src.AnalysisRule ALTER COLUMN AssemblyQualifiedName VARCHAR(200) NULL;
    END;
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_AnalysisRule'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_AnalysisRule ON src.AnalysisRule REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

