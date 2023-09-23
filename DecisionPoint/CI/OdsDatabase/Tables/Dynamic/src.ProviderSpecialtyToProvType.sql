IF OBJECT_ID('src.ProviderSpecialtyToProvType', 'U') IS NULL
BEGIN

CREATE TABLE src.ProviderSpecialtyToProvType(
	OdsPostingGroupAuditId INT NOT NULL,
	OdsCustomerId INT NOT NULL,
	OdsCreateDate DATETIME2(7) NOT NULL,
	OdsSnapshotDate DATETIME2(7) NOT NULL,
	OdsRowIsCurrent BIT NOT NULL,
	OdsHashbytesValue VARBINARY(8000) NULL,
	DmlOperation CHAR(1) NOT NULL,
	ProviderType VARCHAR(20) NOT NULL,
	ProviderType_Desc VARCHAR(80) NULL,
	Specialty VARCHAR(20) NOT NULL,
	Specialty_Desc VARCHAR(80) NULL,
	CreateDate DATETIME NULL,
	ModifyDate DATETIME NULL,
	LogicalDelete CHAR(1) NULL
	) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

ALTER TABLE src.ProviderSpecialtyToProvType ADD CONSTRAINT PK_ProviderSpecialtyToProvType PRIMARY KEY CLUSTERED 
(
	OdsPostingGroupAuditId ASC,
	OdsCustomerId ASC,
	ProviderType ASC,
	Specialty ASC
)WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

ALTER INDEX PK_ProviderSpecialtyToProvType ON src.ProviderSpecialtyToProvType REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
Go

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_ProviderSpecialtyToProvType'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_ProviderSpecialtyToProvType ON src.ProviderSpecialtyToProvType REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO


