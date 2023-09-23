IF OBJECT_ID('stg.Pend', 'U') IS NOT NULL 
	DROP TABLE stg.Pend  
BEGIN
	CREATE TABLE stg.Pend
		(
		  ClientCode CHAR (4) NULL,
		  BillSeq INT NULL,
		  PendSeq SMALLINT NULL,
		  PendDate DATETIME NULL,
		  ReleaseFlag CHAR (1) NULL,
		  PendToID VARCHAR (13) NULL,
		  Priority CHAR (1) NULL,
		  ReleaseDate DATETIME NULL,
		  ReasonCode VARCHAR (8) NULL,
		  PendByUserID CHAR (2) NULL,
		  ReleaseByUserID CHAR (2) NULL,
		  AutoPendFlag CHAR (1) NULL,
		  RuleID CHAR (5) NULL,
		  WFTaskSeq INT NULL,
		  ReleasedByExternalUserName VARCHAR (128) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

