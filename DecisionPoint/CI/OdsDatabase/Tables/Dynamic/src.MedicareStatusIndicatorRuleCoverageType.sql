
IF OBJECT_ID('src.MedicareStatusIndicatorRuleCoverageType', 'U') IS NULL
BEGIN
	CREATE TABLE src.MedicareStatusIndicatorRuleCoverageType (
		OdsPostingGroupAuditId INT NOT NULL,
		OdsCustomerId INT NOT NULL,
		OdsCreateDate DATETIME2(7) NOT NULL,
		OdsSnapshotDate DATETIME2(7) NOT NULL,
		OdsRowIsCurrent BIT NOT NULL,
		OdsHashbytesValue VARBINARY(8000) NULL,
		DmlOperation CHAR(1) NOT NULL,
		MedicareStatusIndicatorRuleId INT NOT NULL,
		ShortName VARCHAR(2) NOT NULL
		) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

	ALTER TABLE src.MedicareStatusIndicatorRuleCoverageType ADD CONSTRAINT PK_MedicareStatusIndicatorRuleCoverageType PRIMARY KEY CLUSTERED (
		OdsPostingGroupAuditId,
		OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		ShortName
		)
		WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_MedicareStatusIndicatorRuleCoverageType ON src.MedicareStatusIndicatorRuleCoverageType REBUILD
		WITH (STATISTICS_INCREMENTAL = ON);
END
ELSE -- We should do below things only when object is not null
BEGIN
	-- If ShortName is nullable, make it not nullable
	IF COLUMNPROPERTY(OBJECT_ID('src.MedicareStatusIndicatorRuleCoverageType', 'U'), 'ShortName', 'AllowsNull') = 1
	BEGIN
		ALTER TABLE src.MedicareStatusIndicatorRuleCoverageType
		ALTER COLUMN ShortName VARCHAR(2) NOT NULL;
	END;

	SET XACT_ABORT ON;

	-- If the PK exists, but is missing our new column, drop and recreate it
	IF OBJECT_ID('src.PK_MedicareStatusIndicatorRuleCoverageType', 'PK') IS NOT NULL
		AND NOT EXISTS (
			SELECT 1
			FROM sys.indexes i
			INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id
				AND i.index_id = ic.index_id
			INNER JOIN sys.columns c ON ic.object_id = c.object_id
				AND ic.column_id = c.column_id
			INNER JOIN sys.objects o ON i.object_id = o.object_id
			WHERE i.is_primary_key = 1
				AND o.object_id = OBJECT_ID('src.MedicareStatusIndicatorRuleCoverageType')
				AND c.name = 'ShortName'
			)
	BEGIN
		BEGIN TRANSACTION;

		ALTER TABLE src.MedicareStatusIndicatorRuleCoverageType
		DROP CONSTRAINT PK_MedicareStatusIndicatorRuleCoverageType;

		ALTER TABLE src.MedicareStatusIndicatorRuleCoverageType ADD CONSTRAINT PK_MedicareStatusIndicatorRuleCoverageType PRIMARY KEY CLUSTERED (
			OdsPostingGroupAuditId,
			OdsCustomerId,
			MedicareStatusIndicatorRuleId,
			ShortName
			)
			WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_MedicareStatusIndicatorRuleCoverageType ON src.MedicareStatusIndicatorRuleCoverageType REBUILD
			WITH (STATISTICS_INCREMENTAL = ON);

		COMMIT TRANSACTION;
	END;
END
GO

