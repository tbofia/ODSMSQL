IF OBJECT_ID('stg.LossYearReport_Client', 'U') IS NOT NULL
DROP TABLE stg.LossYearReport_Client; 
BEGIN
CREATE TABLE stg.LossYearReport_Client 
(
		 ReportID INT
		,ReportName VARCHAR(500)
		,OdsCustomerID INT
		,CompanyName VARCHAR(50)
		,SOJ VARCHAR(2)
		,AgeGroup VARCHAR(50)
		,DateQuarter DATETIME
		,FormType VARCHAR(12)
		,CoverageType VARCHAR(2)
		,EncounterTypePriority INT NULL
		,ServiceGroup VARCHAR(500)
		,RevenueCodeCategoryId INT NULL
		,Gender VARCHAR(3)
		,Outlier_cat VARCHAR(100)
		,ClaimantState VARCHAR(2)
		,ClaimantCounty VARCHAR(200)
		,ProviderSpecialty VARCHAR(50)
		,ProviderState VARCHAR(2)
		,IsAllowedGreaterThanZero INT NULL
		,Allowed MONEY
		,Charged MONEY
		,Units REAL
		,ClaimantCnt INT
		,DOSCnt INT
		,InjuryNatureId INT NULL
		,Period VARCHAR(100) NULL
	    
);
END
GO






