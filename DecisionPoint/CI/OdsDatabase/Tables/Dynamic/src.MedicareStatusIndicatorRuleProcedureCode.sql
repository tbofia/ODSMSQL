
IF OBJECT_ID('src.MedicareStatusIndicatorRuleProcedureCode', 'U') IS NULL
BEGIN
	CREATE TABLE src.MedicareStatusIndicatorRuleProcedureCode (
		OdsPostingGroupAuditId INT NOT NULL,
		OdsCustomerId INT NOT NULL,
		OdsCreateDate DATETIME2(7) NOT NULL,
		OdsSnapshotDate DATETIME2(7) NOT NULL,
		OdsRowIsCurrent BIT NOT NULL,
		OdsHashbytesValue VARBINARY(8000) NULL,
		DmlOperation CHAR(1) NOT NULL,
		MedicareStatusIndicatorRuleId INT NOT NULL,
		ProcedureCode VARCHAR(7) NOT NULL
		) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

	ALTER TABLE src.MedicareStatusIndicatorRuleProcedureCode ADD CONSTRAINT PK_MedicareStatusIndicatorRuleProcedureCode PRIMARY KEY CLUSTERED (
		OdsPostingGroupAuditId,
		OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		ProcedureCode
		)
		WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_MedicareStatusIndicatorRuleProcedureCode ON src.MedicareStatusIndicatorRuleProcedureCode REBUILD
		WITH (STATISTICS_INCREMENTAL = ON);
END
ELSE -- We should do below things only when object is not null
BEGIN
	IF COLUMNPROPERTY(OBJECT_ID('src.MedicareStatusIndicatorRuleProcedureCode', 'U'), 'ProcedureCode', 'AllowsNull') = 1
	BEGIN
		ALTER TABLE src.MedicareStatusIndicatorRuleProcedureCode
		ALTER COLUMN ProcedureCode VARCHAR(7) NOT NULL;
	END;

	SET XACT_ABORT ON;

	-- If the PK exists, but is missing our new column, drop and recreate it
	IF OBJECT_ID('src.PK_MedicareStatusIndicatorRuleProcedureCode', 'PK') IS NOT NULL
		AND NOT EXISTS (
			SELECT 1
			FROM sys.indexes i
			INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id
				AND i.index_id = ic.index_id
			INNER JOIN sys.columns c ON ic.object_id = c.object_id
				AND ic.column_id = c.column_id
			INNER JOIN sys.objects o ON i.object_id = o.object_id
			WHERE i.is_primary_key = 1
				AND o.object_id = OBJECT_ID('src.MedicareStatusIndicatorRuleProcedureCode')
				AND c.name = 'ProcedureCode'
			)
	BEGIN
		BEGIN TRANSACTION;

		ALTER TABLE src.MedicareStatusIndicatorRuleProcedureCode
		DROP CONSTRAINT PK_MedicareStatusIndicatorRuleProcedureCode;

		ALTER TABLE src.MedicareStatusIndicatorRuleProcedureCode ADD CONSTRAINT PK_MedicareStatusIndicatorRuleProcedureCode PRIMARY KEY CLUSTERED (
			OdsPostingGroupAuditId,
			OdsCustomerId,
			MedicareStatusIndicatorRuleId,
			ProcedureCode
			)
			WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_MedicareStatusIndicatorRuleProcedureCode ON src.MedicareStatusIndicatorRuleProcedureCode REBUILD
			WITH (STATISTICS_INCREMENTAL = ON);

		COMMIT TRANSACTION;
	END;
END
GO

