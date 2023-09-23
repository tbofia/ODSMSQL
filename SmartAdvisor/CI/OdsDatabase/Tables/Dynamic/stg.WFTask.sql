IF OBJECT_ID('stg.WFTask', 'U') IS NOT NULL 
	DROP TABLE stg.WFTask  
BEGIN
	CREATE TABLE stg.WFTask
		(
		  WFTaskSeq INT NULL,
		  WFLowSeq INT NULL,
		  WFTaskRegistrySeq INT NULL,
		  Name VARCHAR (35) NULL,
		  Parameter1 VARCHAR (35) NULL,
		  RecordStatus CHAR (1) NULL,
		  NodeLeft NUMERIC (8,2) NULL,
		  NodeTop NUMERIC (8,2) NULL,
		  CreateUserID CHAR (2) NULL,
		  CreateDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  NoPrior CHAR (1) NULL,
		  NoRestart CHAR (1) NULL,
		  ParameterX VARCHAR (2000) NULL,
		  DefaultPendGroup VARCHAR (12) NULL,
		  Configuration NVARCHAR (2000) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

