IF OBJECT_ID('stg.WFQueue', 'U') IS NOT NULL 
	DROP TABLE stg.WFQueue  
BEGIN
	CREATE TABLE stg.WFQueue
		(
		  EntityTypeCode CHAR (2) NULL,
		  EntitySubset CHAR (4) NULL,
		  EntitySeq BIGINT NULL,
		  WFTaskSeq INT NULL,
		  PriorWFTaskSeq INT NULL,
		  Status CHAR (1) NULL,
		  Priority CHAR (1) NULL,
		  CreateUserID CHAR (2) NULL,
		  CreateDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  TaskMessage VARCHAR (500) NULL,
		  Parameter1 VARCHAR (35) NULL,
		  ContextID VARCHAR (256) NULL,
		  PriorStatus CHAR (1) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

