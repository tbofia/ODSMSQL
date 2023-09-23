IF OBJECT_ID('stg.Medispan', 'U') IS NOT NULL 
	DROP TABLE stg.Medispan  
BEGIN
	CREATE TABLE stg.Medispan
		(
		  NDC CHAR (11) NULL,
		  DEA VARCHAR (5) NULL,
		  Name1 VARCHAR (25) NULL,
		  Name2 VARCHAR (4) NULL,
		  Name3 VARCHAR (11) NULL,
		  Strength INT NULL,
		  Unit INT NULL,
		  Pkg CHAR (2) NULL,
		  Factor SMALLINT NULL,
		  GenericDrug CHAR (1) NULL,
		  Desicode CHAR (1) NULL,
		  Rxotc CHAR (1) NULL,
		  GPI VARCHAR (14) NULL,
		  Awp1 INT NULL,
		  Awp0 INT NULL,
		  Awp2 INT NULL,
		  EffectiveDt2 DATETIME NULL,
		  EffectiveDt1 DATETIME NULL,
		  EffectiveDt0 DATETIME NULL,
		  FDAEquivalence CHAR (3) NULL,
		  NDCFormat CHAR (1) NULL,
		  RestrictDrugs CHAR (1) NULL,
		  GPPC VARCHAR (8) NULL,
		  Status CHAR (1) NULL,
		  UpdateDate DATETIME NULL,
		  AAWP INT NULL,
		  GAWP INT NULL,
		  RepackagedCode VARCHAR (2) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

