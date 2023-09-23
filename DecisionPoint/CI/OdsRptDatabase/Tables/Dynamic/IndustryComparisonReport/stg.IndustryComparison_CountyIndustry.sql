IF OBJECT_ID('stg.IndustryComparison_CountyIndustry', 'U') IS NOT NULL
DROP TABLE stg.IndustryComparison_CountyIndustry
BEGIN
CREATE TABLE stg.IndustryComparison_CountyIndustry(
	ReportName varchar(6) NOT NULL,
	CoverageType varchar(20) NULL,
	FormType varchar(20) NULL,
	State varchar(20) NULL,
	County varchar(50) NULL,
	Year int NULL,
	Quarter int NULL,
	IndTotalClaims int NULL,
	IndTotalClaimants int NULL,
	IndTotalCharged money NULL,
	IndTotalAllowed money NULL,
	IndTotalReductions money NULL,
	IndTotalBills int NULL,
	IndTotalUnits numeric(9, 2) NULL,
	IndTotalLines int NULL
)
END
GO


