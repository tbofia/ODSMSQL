
IF OBJECT_ID('src.MedicareStatusIndicatorRulePlaceOfService', 'U') IS NULL
BEGIN
	CREATE TABLE src.MedicareStatusIndicatorRulePlaceOfService (
		OdsPostingGroupAuditId INT NOT NULL,
		OdsCustomerId INT NOT NULL,
		OdsCreateDate DATETIME2(7) NOT NULL,
		OdsSnapshotDate DATETIME2(7) NOT NULL,
		OdsRowIsCurrent BIT NOT NULL,
		OdsHashbytesValue VARBINARY(8000) NULL,
		DmlOperation CHAR(1) NOT NULL,
		MedicareStatusIndicatorRuleId INT NOT NULL,
		PlaceOfService VARCHAR(4) NOT NULL
		) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

	ALTER TABLE src.MedicareStatusIndicatorRulePlaceOfService ADD CONSTRAINT PK_MedicareStatusIndicatorRulePlaceOfService PRIMARY KEY CLUSTERED (
		OdsPostingGroupAuditId,
		OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		PlaceOfService
		)
		WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_MedicareStatusIndicatorRulePlaceOfService ON src.MedicareStatusIndicatorRulePlaceOfService REBUILD
		WITH (STATISTICS_INCREMENTAL = ON);
END
ELSE
BEGIN
	IF EXISTS (
			SELECT 1
			FROM sys.columns sc
			INNER JOIN sys.types st ON sc.user_type_id = st.user_type_id
			WHERE sc.object_id = OBJECT_ID('src.MedicareStatusIndicatorRulePlaceOfService')
				AND sc.name = 'PlaceOfService'
				AND NOT (
					st.name = 'varchar'
					AND sc.max_length = 4
					)
			)
		AND (COLUMNPROPERTY(OBJECT_ID('src.MedicareStatusIndicatorRulePlaceOfService', 'U'), 'PlaceOfService', 'AllowsNull') = 1)
	BEGIN
		ALTER TABLE src.MedicareStatusIndicatorRulePlaceOfService
		ALTER COLUMN PlaceOfService VARCHAR(4) NOT NULL;
	END;

	SET XACT_ABORT ON;

	IF OBJECT_ID('src.PK_MedicareStatusIndicatorRulePlaceOfService', 'PK') IS NOT NULL
		AND NOT EXISTS (
			SELECT 1
			FROM sys.indexes i
			INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id
				AND i.index_id = ic.index_id
			INNER JOIN sys.columns c ON ic.object_id = c.object_id
				AND ic.column_id = c.column_id
			INNER JOIN sys.objects o ON i.object_id = o.object_id
			WHERE i.is_primary_key = 1
				AND o.object_id = OBJECT_ID('src.MedicareStatusIndicatorRulePlaceOfService')
				AND c.name = 'PlaceOfService'
			)
	BEGIN
		BEGIN TRANSACTION;

		ALTER TABLE src.MedicareStatusIndicatorRulePlaceOfService
		DROP CONSTRAINT PK_MedicareStatusIndicatorRulePlaceOfService;

		ALTER TABLE src.MedicareStatusIndicatorRulePlaceOfService ADD CONSTRAINT PK_MedicareStatusIndicatorRulePlaceOfService PRIMARY KEY CLUSTERED (
			OdsPostingGroupAuditId,
			OdsCustomerId,
			MedicareStatusIndicatorRuleId,
			PlaceOfService
			)
			WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_MedicareStatusIndicatorRulePlaceOfService ON src.MedicareStatusIndicatorRulePlaceOfService REBUILD
			WITH (STATISTICS_INCREMENTAL = ON);

		COMMIT TRANSACTION;
	END;
END
GO

IF  EXISTS ( SELECT  1
			FROM    sys.columns c 
					INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
			WHERE   object_id = OBJECT_ID(N'src.MedicareStatusIndicatorRulePlaceOfService')
					AND c.name = 'PlaceOfService' 
					AND NOT ( t.name = 'VARCHAR' 
						 AND c.max_length = '4'
						   ) ) 
	BEGIN
		ALTER TABLE src.MedicareStatusIndicatorRulePlaceOfService ALTER COLUMN PlaceOfService VARCHAR(4) NOT NULL ;
	END 
GO
IF  EXISTS ( SELECT  1
			FROM    sys.columns c 
					INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
			WHERE   object_id = OBJECT_ID(N'src.MedicareStatusIndicatorRulePlaceOfService')
					AND c.name = 'PlaceOfService' 
					AND NOT ( t.name = 'VARCHAR' 
						 AND c.max_length = '4'
						   ) ) 
	BEGIN
		ALTER TABLE src.MedicareStatusIndicatorRulePlaceOfService ALTER COLUMN PlaceOfService VARCHAR(4) NOT NULL ;
	END 
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1 
                FROM sys.stats
                 WHERE name ='MedicareStatusIndicatorRulePlaceOfService' 
                 AND is_incremental = 1)  BEGIN
ALTER INDEX PK_MedicareStatusIndicatorRulePlaceOfService ON src.MedicareStatusIndicatorRulePlaceOfService   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
END ;
GO


