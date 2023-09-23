IF OBJECT_ID('stg.StateSettingMedicare', 'U') IS NOT NULL 
	DROP TABLE stg.StateSettingMedicare  
BEGIN
	CREATE TABLE stg.StateSettingMedicare
		(
		  StateSettingMedicareId INT NULL,
		  PayPercentOfMedicareFee BIT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

