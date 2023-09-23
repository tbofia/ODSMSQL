IF OBJECT_ID('stg.MedicareStatusIndicatorRulePlaceOfService', 'U') IS NOT NULL 
	DROP TABLE stg.MedicareStatusIndicatorRulePlaceOfService  
BEGIN
	CREATE TABLE stg.MedicareStatusIndicatorRulePlaceOfService
		(
		  MedicareStatusIndicatorRuleId INT NULL,
		  PlaceOfService VARCHAR (4) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

