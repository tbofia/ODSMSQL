IF OBJECT_ID('dbo.LossYearReport', 'U') IS NULL
BEGIN
	CREATE TABLE dbo.LossYearReport (
		 ReportName VARCHAR(255) NOT NULL
		,OdsCustomerId INT NOT NULL
		,CustomerName VARCHAR(255) NOT NULL
		,CompanyName VARCHAR(max) NULL
		,SOJ VARCHAR(2) NULL
		,AgeGroup VARCHAR(100) NULL
		,YOL VARCHAR(4) NULL
		,Year INT NULL
		,Quarter VARCHAR(8) NULL
		,DateQuarter DATETIME NULL
		,FormType VARCHAR(20) NULL
		,CoverageType VARCHAR(5) NULL
		,CoverageTypeDesc VARCHAR(100) NULL
		,InjuryNatureId INT NULL
	    ,InjuryNatureDesc VARCHAR(MAX) NULL
		,EncounterTypeId INT NULL
		,EncounterTypeDesc VARCHAR(MAX) NULL
		,Period VARCHAR(100) NULL
		,ServiceGroup VARCHAR(max) NULL
		,RevenueGroup VARCHAR(max) NULL
		,BillType VARCHAR(200) NULL
		,Gender VARCHAR(2) NULL
		,OutlierCat VARCHAR(max) NULL
		,ClaimantState VARCHAR(2) NULL
		,ClaimantCounty VARCHAR(100) NULL
		,ProviderState VARCHAR(2) NULL
		,ProviderSpecialty VARCHAR(500) NULL
		,PlaceOfService VARCHAR(250) NULL
		,InjuryType VARCHAR(500) NULL
		,ClaimCnt INT NULL
		,IndClaimCnt INT NULL
		,ClaimantCnt INT NULL
		,IndClaimantCnt INT NULL
		,ProviderCnt INT NULL
		,IndProviderCnt INT NULL
		,BillCnt INT NULL
		,IndBillCnt INT NULL
		,DOSCnt INT NULL
		,IndDOSCnt INT NULL
		,LineCnt INT NULL
		,IndLineCnt INT NULL
		,UnitsCnt INT NULL
		,IndUnitsCnt INT NULL
		,Charged MONEY NULL
		,IndCharged MONEY NULL
		,Allowed MONEY NULL
		,IndAllowed MONEY NULL
		,IsAllowedGreaterThanZero INT NULL
		,RunDate DATETIME NOT NULL DEFAULT GETDATE()
		)ON rpt_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);
END
GO

