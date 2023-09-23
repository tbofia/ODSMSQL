IF OBJECT_ID('stg.ManualProviderSpecialty', 'U') IS NOT NULL 
	DROP TABLE stg.ManualProviderSpecialty  
BEGIN
	CREATE TABLE stg.ManualProviderSpecialty
		(
		  ManualProviderId INT NULL,
		  Specialty VARCHAR (12) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

