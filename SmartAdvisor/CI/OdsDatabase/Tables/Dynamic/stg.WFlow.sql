IF OBJECT_ID('stg.WFlow', 'U') IS NOT NULL 
	DROP TABLE stg.WFlow  
BEGIN
	CREATE TABLE stg.WFlow
		(
		  WFlowSeq INT NULL,
		  Description VARCHAR (50) NULL,
		  RecordStatus CHAR (1) NULL,
		  EntityTypeCode CHAR (2) NULL,
		  CreateUserID CHAR (2) NULL,
		  CreateDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  InitialTaskSeq INT NULL,
		  PauseTaskSeq INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

