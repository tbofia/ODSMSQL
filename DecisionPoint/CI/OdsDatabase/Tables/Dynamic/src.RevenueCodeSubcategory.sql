IF OBJECT_ID('src.RevenueCodeSubcategory', 'U') IS NULL
	BEGIN
		CREATE TABLE src.RevenueCodeSubcategory
			(
			OdsPostingGroupAuditId INT NOT NULL ,
			OdsCustomerId INT NOT NULL ,
			OdsCreateDate DATETIME2(7) NOT NULL ,
			OdsSnapshotDate DATETIME2(7) NOT NULL ,
			OdsRowIsCurrent BIT NOT NULL ,
			OdsHashbytesValue VARBINARY(8000) NULL ,
			DmlOperation CHAR(1) NOT NULL ,
			RevenueCodeSubcategoryId TINYINT NOT NULL,
			RevenueCodeCategoryId TINYINT NULL,
			Description VARCHAR(100) NULL,
			NarrativeInformation VARCHAR(1000) NULL
			)ON DP_Ods_PartitionScheme(OdsCustomerId)
						WITH (
							 DATA_COMPRESSION = PAGE);

		ALTER TABLE src.RevenueCodeSubcategory ADD 
		CONSTRAINT PK_RevenueCodeSubcategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, RevenueCodeSubcategoryId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_RevenueCodeSubcategory ON src.RevenueCodeSubcategory REBUILD WITH(STATISTICS_INCREMENTAL = ON);
	END
GO
