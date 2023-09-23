
IF OBJECT_ID('stg.MedicareStatusIndicatorRuleProcedureCode', 'U') IS NOT NULL
DROP TABLE stg.MedicareStatusIndicatorRuleProcedureCode
BEGIN
	CREATE TABLE stg.MedicareStatusIndicatorRuleProcedureCode (
		MedicareStatusIndicatorRuleId INT NULL,
        ProcedureCode VARCHAR(7) NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO


