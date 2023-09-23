IF OBJECT_ID('stg.PendComment', 'U') IS NOT NULL 
	DROP TABLE stg.PendComment  
BEGIN
	CREATE TABLE stg.PendComment
		(
		  ClientCode CHAR (4) NULL,
		  BillSeq INT NULL,
		  PendSeq SMALLINT NULL,
		  PendCommentSeq SMALLINT NULL,
		  PendComment VARCHAR (7500) NULL,
		  CreateUserID VARCHAR (2) NULL,
		  CreateDate DATETIME NULL,
		  CreatedByExternalUserName VARCHAR (128) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

