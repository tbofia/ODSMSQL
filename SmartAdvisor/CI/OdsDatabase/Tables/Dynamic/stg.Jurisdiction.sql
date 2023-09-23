IF OBJECT_ID('stg.Jurisdiction', 'U') IS NOT NULL 
	DROP TABLE stg.Jurisdiction  
BEGIN
	CREATE TABLE stg.Jurisdiction
		(
		  JurisdictionID CHAR (2) NULL,
		  Name VARCHAR (30) NULL,
		  POSTableCode CHAR (2) NULL,
		  TOSTableCode CHAR (2) NULL,
		  TOBTableCode CHAR (2) NULL,
		  ProvTypeTableCode CHAR (2) NULL,
		  Hospital CHAR (1) NULL,
		  ProvSpclTableCode CHAR (2) NULL,
		  DaysToPay SMALLINT NULL,
		  DaysToPayQualify CHAR (2) NULL,
		  OutPatientFS CHAR (1) NULL,
		  ProcFileVer CHAR (1) NULL,
		  AnestUnit SMALLINT NULL,
		  AnestRndUp SMALLINT NULL,
		  AnestFormat CHAR (1) NULL,
		  StateMandateSSN CHAR (1) NULL,
		  ICDEdition SMALLINT NULL,
		  ICD10ComplianceDate DATETIME NULL,
		  eBillsDaysToPay SMALLINT NULL,
		  eBillsDaysToPayQualify CHAR (2) NULL,
		  DisputeDaysToPay SMALLINT NULL,
		  DisputeDaysToPayQualify CHAR (2) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

