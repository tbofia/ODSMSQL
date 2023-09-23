IF OBJECT_ID('stg.LossYearReport_Filtered', 'U') IS NOT NULL
DROP TABLE stg.LossYearReport_Filtered
BEGIN
	CREATE TABLE stg.LossYearReport_Filtered (
		OdsCustomerId INT NOT NULL
		,CompanyName VARCHAR(50) NULL
		,SOJ VARCHAR(2) NULL
		,AgeGroup VARCHAR(50) NULL
		,DateQuarter DATETIME NULL
		,FormType VARCHAR(12) NULL
		,CoverageType VARCHAR(2) NULL
		,EncounterTypePriority INT NULL
		,ServiceGroup VARCHAR(500) NULL
		,RevenueCodeCategoryId INT NULL
		,Gender VARCHAR(2) NULL
		,Outlier_cat VARCHAR(100) NULL
		,ClaimantState VARCHAR(2) NULL
		,ClaimantCounty VARCHAR(50) NULL
		,ProviderSpecialty VARCHAR(50) NULL
		,ProviderState VARCHAR(10) NULL
		,InjuryNatureId INT NULL
		,CmtIdNo INT NULL
		,DT_SVC DATETIME NULL
		,Period VARCHAR(80) NULL
		,IsAllowedGreaterThanZero INT NOT NULL
		,Allowed MONEY NULL
		,Charged MONEY NULL
		,Units REAL NULL
		);
END
GO
