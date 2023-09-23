
IF OBJECT_ID('stg.MedicareStatusIndicatorRuleProviderSpecialty', 'U') IS NOT NULL
DROP TABLE stg.MedicareStatusIndicatorRuleProviderSpecialty
BEGIN
	CREATE TABLE stg.MedicareStatusIndicatorRuleProviderSpecialty (
		MedicareStatusIndicatorRuleId INT NULL,
        ProviderSpecialty VARCHAR(6) NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO


