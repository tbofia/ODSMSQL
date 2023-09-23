IF OBJECT_ID('src.ProviderCluster', 'U') IS NULL
    BEGIN
        CREATE TABLE src.ProviderCluster
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  ProviderSubSet CHAR(4) NOT NULL,
			  ProviderSeq BIGINT NOT NULL, 
			  OrgOdsCustomerId INT NOT NULL,
			  MitchellProviderKey VARCHAR(200) NULL,
			  ProviderClusterKey VARCHAR(200) NULL,
			  ProviderType VARCHAR(30) NULL,

            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.ProviderCluster ADD 
        CONSTRAINT PK_ProviderCluster PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,ProviderSubSet , ProviderSeq ,OrgOdsCustomerId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);
		
		ALTER INDEX PK_ProviderCluster ON src.ProviderCluster REBUILD WITH(STATISTICS_INCREMENTAL = ON);

	END
GO

