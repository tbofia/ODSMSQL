
IF OBJECT_ID('src.MedicareStatusIndicatorRuleProviderSpecialty', 'U') IS NULL
BEGIN
	CREATE TABLE src.MedicareStatusIndicatorRuleProviderSpecialty (
		OdsPostingGroupAuditId INT NOT NULL,
		OdsCustomerId INT NOT NULL,
		OdsCreateDate DATETIME2(7) NOT NULL,
		OdsSnapshotDate DATETIME2(7) NOT NULL,
		OdsRowIsCurrent BIT NOT NULL,
		OdsHashbytesValue VARBINARY(8000) NULL,
		DmlOperation CHAR(1) NOT NULL,
		MedicareStatusIndicatorRuleId INT NOT NULL,
		ProviderSpecialty VARCHAR(6) NOT NULL
		) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

	ALTER TABLE src.MedicareStatusIndicatorRuleProviderSpecialty ADD CONSTRAINT PK_MedicareStatusIndicatorRuleProviderSpecialty PRIMARY KEY CLUSTERED (
		OdsPostingGroupAuditId,
		OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		ProviderSpecialty
		)
		WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_MedicareStatusIndicatorRuleProviderSpecialty ON src.MedicareStatusIndicatorRuleProviderSpecialty REBUILD
		WITH (STATISTICS_INCREMENTAL = ON);
END
ELSE -- We should do below things only when object is not null
BEGIN
	IF COLUMNPROPERTY(OBJECT_ID('src.MedicareStatusIndicatorRuleProviderSpecialty', 'U'), 'ProviderSpecialty', 'AllowsNull') = 1
	BEGIN
		ALTER TABLE src.MedicareStatusIndicatorRuleProviderSpecialty
		ALTER COLUMN ProviderSpecialty VARCHAR(6) NOT NULL;
	END;

	SET XACT_ABORT ON;

	-- If the PK exists, but is missing our new column, drop and recreate it
	IF OBJECT_ID('src.PK_MedicareStatusIndicatorRuleProviderSpecialty', 'PK') IS NOT NULL
		AND NOT EXISTS (
			SELECT 1
			FROM sys.indexes i
			INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id
				AND i.index_id = ic.index_id
			INNER JOIN sys.columns c ON ic.object_id = c.object_id
				AND ic.column_id = c.column_id
			INNER JOIN sys.objects o ON i.object_id = o.object_id
			WHERE i.is_primary_key = 1
				AND o.object_id = OBJECT_ID('src.MedicareStatusIndicatorRuleProviderSpecialty')
				AND c.name = 'ProviderSpecialty'
			)
	BEGIN
		BEGIN TRANSACTION;

		ALTER TABLE src.MedicareStatusIndicatorRuleProviderSpecialty
		DROP CONSTRAINT PK_MedicareStatusIndicatorRuleProviderSpecialty;

		ALTER TABLE src.MedicareStatusIndicatorRuleProviderSpecialty ADD CONSTRAINT PK_MedicareStatusIndicatorRuleProviderSpecialty PRIMARY KEY CLUSTERED (
			OdsPostingGroupAuditId,
			OdsCustomerId,
			MedicareStatusIndicatorRuleId,
			ProviderSpecialty
			)
			WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_MedicareStatusIndicatorRuleProviderSpecialty ON src.MedicareStatusIndicatorRuleProviderSpecialty REBUILD
			WITH (STATISTICS_INCREMENTAL = ON);

		COMMIT TRANSACTION;
	END;
END
GO

