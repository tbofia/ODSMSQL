IF OBJECT_ID('stg.NcciBodyPartToHybridBodyPartTranslation', 'U') IS NOT NULL 
	DROP TABLE stg.NcciBodyPartToHybridBodyPartTranslation  
BEGIN
	CREATE TABLE stg.NcciBodyPartToHybridBodyPartTranslation
		(
		  NcciBodyPartId TINYINT NULL,
		  HybridBodyPartId SMALLINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

