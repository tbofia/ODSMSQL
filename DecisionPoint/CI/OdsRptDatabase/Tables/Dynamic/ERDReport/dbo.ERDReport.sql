IF OBJECT_ID('dbo.ERDReport', 'U') IS NULL
BEGIN
	CREATE TABLE dbo.ERDReport (
		  OdsCustomerId INT NOT NULL,
		  ReportName VARCHAR(500) NULL,
		  CustomerName VARCHAR(500) NULL,
		  ClaimIDNo INT NULL,
		  ClaimNo VARCHAR(500) NULL,
		  ClaimantIDNo INT NULL,
		  CoverageType VARCHAR(2) NULL,
		  CoverageTypeDesc VARCHAR(200) NULL,
		  Company VARCHAR(250) NULL,
		  Office VARCHAR(250) NULL,
		  SOJ VARCHAR(2) NULL,
		  County VARCHAR(100) NULL,
		  AdjustorFirstName VARCHAR(200) NULL,
		  AdjustorLastName VARCHAR(200) NULL,
		  ClaimDateLoss DATETIME NULL,
		  LastDateOfService DATETIME NULL,
		  InjuryNatureId INT NULL,
		  InjuryNatureDesc VARCHAR(250),
		  ERDDuration_Weeks INT NULL,
		  ERDDuration_Days INT NULL,
		  AllowedTreatmentDuration_Days INT NULL,
		  AllowedTreatmentDuration_Weeks INT NULL,
		  Charged MONEY NULL,
		  Allowed MONEY NULL,
		  ChargedAfterERD MONEY NULL,
		  AllowedAfterERD MONEY NULL,
		  RunDate DATETIME NULL
		);
END
GO
