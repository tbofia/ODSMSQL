IF OBJECT_ID('stg.EDIXmit', 'U') IS NOT NULL 
	DROP TABLE stg.EDIXmit  
BEGIN
	CREATE TABLE stg.EDIXmit
		(
		  EDIXmitSeq INT NULL,
		  FileSpec VARCHAR (8000) NULL,
		  FileLocation VARCHAR (255) NULL,
		  RecommendedPayment MONEY NULL,
		  UserID CHAR (2) NULL,
		  XmitDate DATETIME NULL,
		  DateFrom DATETIME NULL,
		  DateTo DATETIME NULL,
		  EDIType CHAR (1) NULL,
		  EDIPartnerID CHAR (3) NULL,
		  DBVersion VARCHAR (20) NULL,
		  EDIMapToolSiteCode CHAR (3) NULL,
		  EDIPortType CHAR (1) NULL,
		  EDIMapToolID INT NULL,
		  TransmissionStatus CHAR (1) NULL,
		  BatchNumber INT NULL,
		  SenderID VARCHAR (20) NULL,
		  ReceiverID VARCHAR (20) NULL,
		  ExternalBatchID VARCHAR (50) NULL,
		  SARelatedBatchID BIGINT NULL,
		  AckNoteCode CHAR (3) NULL,
		  AckNote VARCHAR (50) NULL,
		  ExternalBatchDate DATETIME NULL,
		  UserNotes VARCHAR (1000) NULL,
		  ResubmitDate DATETIME NULL,
		  ResubmitUserID VARCHAR (2) NULL,
		  ModDate DATETIME NULL,
		  ModUserID VARCHAR (2) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

