IF OBJECT_ID('src.RevenueCodeCategory', 'U') IS NULL
BEGIN
	CREATE TABLE src.RevenueCodeCategory
		(
			OdsPostingGroupAuditId INT NOT NULL ,
			OdsCustomerId INT NOT NULL , 
			OdsCreateDate DATETIME2(7) NOT NULL ,
			OdsSnapshotDate DATETIME2(7) NOT NULL ,
			OdsRowIsCurrent BIT NOT NULL ,
			OdsHashbytesValue VARBINARY(8000) NULL,
			DmlOperation CHAR(1) NOT NULL ,
			RevenueCodeCategoryId TINYINT NOT NULL,
			Description VARCHAR(100) NULL,
			NarrativeInformation VARCHAR(1000) NULL

			)ON DP_Ods_PartitionScheme(OdsCustomerId)
						WITH (
						 DATA_COMPRESSION = PAGE);

		ALTER TABLE src.RevenueCodeCategory ADD 
		CONSTRAINT PK_RevenueCodeCategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,RevenueCodeCategoryId ASC) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_RevenueCodeCategory ON src.RevenueCodeCategory REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO
