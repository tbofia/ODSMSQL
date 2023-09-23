IF OBJECT_ID('src.ProviderSpecialty', 'U') IS NULL
    BEGIN
        CREATE TABLE src.ProviderSpecialty
            ( OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              ProviderId INT NOT NULL ,
              SpecialtyCode VARCHAR(50) NOT NULL               
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.ProviderSpecialty ADD 
        CONSTRAINT PK_ProviderSpecialty PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProviderId, SpecialtyCode) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_ProviderSpecialty ON src.ProviderSpecialty REBUILD WITH(STATISTICS_INCREMENTAL = ON);
    END
GO

IF  EXISTS (SELECT  1
			FROM    sys.columns c 
					INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
			WHERE   object_id = OBJECT_ID(N'src.ProviderSpecialty')
					AND c.name = 'SpecialtyCode' 
					AND t.name = 'VARCHAR' 
					AND c.max_length = '12') 
	BEGIN
		
		IF EXISTS (
		SELECT object_id
		FROM sys.indexes
		WHERE object_id = OBJECT_ID(N'src.ProviderSpecialty')
			AND NAME = N'PK_ProviderSpecialty')
			ALTER TABLE src.ProviderSpecialty  DROP CONSTRAINT PK_ProviderSpecialty;
		
		ALTER TABLE src.ProviderSpecialty ALTER COLUMN SpecialtyCode VARCHAR(50) NOT NULL;

		ALTER TABLE src.ProviderSpecialty ADD 
        CONSTRAINT PK_ProviderSpecialty PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProviderId, SpecialtyCode) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_ProviderSpecialty ON src.ProviderSpecialty REBUILD WITH(STATISTICS_INCREMENTAL = ON);

	END ; 
GO
