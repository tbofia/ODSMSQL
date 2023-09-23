IF OBJECT_ID('stg.LossYearReport_Industry', 'U') IS NOT NULL
DROP TABLE stg.LossYearReport_Industry
BEGIN
CREATE TABLE stg.LossYearReport_Industry (
	 ReportID INT NULL
	,ReportName VARCHAR(500) NULL
	,SOJ VARCHAR(2) NULL
	,AgeGroup VARCHAR(50) NULL
	,DateQuarter DATETIME NULL
	,FormType VARCHAR(12) NULL
	,CoverageType VARCHAR(2) NULL
	,EncounterTypePriority INT NULL
	,ServiceGroup VARCHAR(500) NULL
	,RevenueCodeCategoryId INT NULL
	,Gender VARCHAR(3) NULL
	,Outlier_cat VARCHAR(100) NULL
	,ClaimantState VARCHAR(2) NULL
	,ClaimantCounty VARCHAR(200) NULL
	,ProviderSpecialty VARCHAR(50) NULL
	,ProviderState VARCHAR(2) NULL
	,IsAllowedGreaterThanZero INT NULL
	,IndAllowed MONEY NULL
	,IndCharged MONEY NULL
	,IndUnits FLOAT NULL
	,IndClaimantCnt INT NULL
	,IndDOSCnt INT NULL
	,InjuryNatureId INT NULL
	,Period VARCHAR(100) NULL
	
);
END
GO

