IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.LossYearReport_Industry') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.LossYearReport_Industry
GO

CREATE PROCEDURE  dbo.LossYearReport_Industry(
@SourceDatabaseName VARCHAR(50)='AcsOds') 
AS
BEGIN
DECLARE @SQL VARCHAR(MAX);

ALTER INDEX ALL ON  stg.LossYearReport_Industry DISABLE;

SET @SQL = CAST ('' AS VARCHAR(MAX)) +'
TRUNCATE TABLE stg.LossYearReport_Industry;

INSERT INTO stg.LossYearReport_Industry
SELECT  ReportID,
		ReportName,
		SOJ, 
		AgeGroup, 
		DateQuarter, 
		FormType,
		CoverageType,
		EncounterTypePriority,
		ServiceGroup,
		RevenueCodeCategoryId,
		Gender, 
		Outlier_cat, 
		ClaimantState, 
		ClaimantCounty,
		ProviderSpecialty, 
		ProviderState, 
		IsAllowedGreaterThanZero,
		SUM(Allowed) IndAllowed, 
		SUM(Charged) IndCharged, 
		SUM(UNITS) IndUnits, 
		SUM(ClaimantCnt) IndClaimantCnt, 
		SUM(DOSCnt) IndDOSCnt,
		InjuryNatureId,
		Period
FROM stg.LossYearReport_Client
GROUP BY
		ReportID, 
		ReportName,
		SOJ, 
		AgeGroup, 
		DateQuarter, 
		FormType,
		CoverageType,
		EncounterTypePriority,
		ServiceGroup,
		RevenueCodeCategoryId,
		Gender, 
		Outlier_cat, 
		ClaimantState,
		ClaimantCounty, 
		ProviderSpecialty, 
		ProviderState,
		IsAllowedGreaterThanZero,
		InjuryNatureId,
		Period;'

EXEC(@SQL);

ALTER INDEX ALL ON  stg.LossYearReport_Industry REBUILD;
		
END

GO
