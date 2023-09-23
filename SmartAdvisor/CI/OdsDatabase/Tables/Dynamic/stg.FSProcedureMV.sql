IF OBJECT_ID('stg.FSProcedureMV', 'U') IS NOT NULL 
	DROP TABLE stg.FSProcedureMV  
BEGIN
	CREATE TABLE stg.FSProcedureMV
		(
		  Jurisdiction CHAR (2) NULL,
		  Extension CHAR (3) NULL,
		  ProcedureCode CHAR (6) NULL,
		  EffectiveDate DATETIME NULL,
		  TerminationDate DATETIME NULL,
		  FSProcDescription VARCHAR (24) NULL,
		  Sv CHAR (1) NULL,
		  Star CHAR (1) NULL,
		  Panel CHAR (1) NULL,
		  Ip CHAR (1) NULL,
		  Mult CHAR (1) NULL,
		  AsstSurgeon CHAR (1) NULL,
		  SectionFlag CHAR (1) NULL,
		  Fup CHAR (3) NULL,
		  Bav SMALLINT NULL,
		  ProcGroup CHAR (4) NULL,
		  ViewType SMALLINT NULL,
		  UnitValue MONEY NULL,
		  ProUnitValue MONEY NULL,
		  TechUnitValue MONEY NULL,
		  SiteCode CHAR (3) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

