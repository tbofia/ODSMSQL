
IF OBJECT_ID('stg.MedicareStatusIndicatorRuleCoverageType', 'U') IS NOT NULL
DROP TABLE stg.MedicareStatusIndicatorRuleCoverageType
BEGIN
	CREATE TABLE stg.MedicareStatusIndicatorRuleCoverageType (
		MedicareStatusIndicatorRuleId INT NULL,
        ShortName VARCHAR(2) NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO


