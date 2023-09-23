IF OBJECT_ID('stg.CriticalAccessHospitalInpatientRevenueCode', 'U') IS NOT NULL 
	DROP TABLE stg.CriticalAccessHospitalInpatientRevenueCode  
BEGIN
	CREATE TABLE stg.CriticalAccessHospitalInpatientRevenueCode
		(
		  RevenueCode VARCHAR (4) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

