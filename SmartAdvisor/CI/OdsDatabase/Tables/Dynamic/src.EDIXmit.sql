IF OBJECT_ID('src.EDIXmit', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.EDIXmit
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  EDIXmitSeq INT NOT NULL ,
			  FileSpec VARCHAR (8000) NULL ,
			  FileLocation VARCHAR (255) NULL ,
			  RecommendedPayment MONEY NULL ,
			  UserID CHAR (2) NULL ,
			  XmitDate DATETIME NULL ,
			  DateFrom DATETIME NULL ,
			  DateTo DATETIME NULL ,
			  EDIType CHAR (1) NULL ,
			  EDIPartnerID CHAR (3) NULL ,
			  DBVersion VARCHAR (20) NULL ,
			  EDIMapToolSiteCode CHAR (3) NULL ,
			  EDIPortType CHAR (1) NULL ,
			  EDIMapToolID INT NULL ,
			  TransmissionStatus CHAR (1) NULL ,
			  BatchNumber INT NULL ,
			  SenderID VARCHAR (20) NULL ,
			  ReceiverID VARCHAR (20) NULL ,
			  ExternalBatchID VARCHAR (50) NULL ,
			  SARelatedBatchID BIGINT NULL ,
			  AckNoteCode CHAR (3) NULL ,
			  AckNote VARCHAR (50) NULL ,
			  ExternalBatchDate DATETIME NULL ,
			  UserNotes VARCHAR (1000) NULL ,
			  ResubmitDate DATETIME NULL ,
			  ResubmitUserID VARCHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  ModUserID VARCHAR (2) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.EDIXmit ADD 
     CONSTRAINT PK_EDIXmit PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, EDIXmitSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_EDIXmit ON src.EDIXmit   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
