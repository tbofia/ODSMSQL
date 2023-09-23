IF OBJECT_ID('stg.lkp_SPC', 'U') IS NOT NULL 
	DROP TABLE stg.lkp_SPC  
BEGIN
	CREATE TABLE stg.lkp_SPC
		(
		  lkp_SpcId INT NULL,
		  LongName VARCHAR (50) NULL,
		  ShortName VARCHAR (4) NULL,
		  Mult MONEY NULL,
		  NCD92 SMALLINT NULL,
		  NCD93 SMALLINT NULL,
		  PlusFour SMALLINT NULL,
		  CbreSpecialtyCode VARCHAR (12) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

