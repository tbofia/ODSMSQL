IF OBJECT_ID('stg.lkp_TS', 'U') IS NOT NULL 
	DROP TABLE stg.lkp_TS  
BEGIN
	CREATE TABLE stg.lkp_TS
		(
		  ShortName VARCHAR (2) NULL,
		  StartDate DATETIME2 (7) NULL,
		  EndDate DATETIME2 (7) NULL,
		  LongName VARCHAR (100) NULL,
		  GLOBAL SMALLINT NULL,
		  AnesMedDirect SMALLINT NULL,
		  AffectsPricing SMALLINT NULL,
		  IsAssistantSurgery BIT NULL,
		  IsCoSurgeon BIT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

