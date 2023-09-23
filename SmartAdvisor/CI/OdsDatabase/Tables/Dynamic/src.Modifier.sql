IF OBJECT_ID('src.Modifier', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Modifier
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  Jurisdiction CHAR (2) NOT NULL ,
			  Code VARCHAR (6) NOT NULL ,
			  SiteCode CHAR (3) NOT NULL ,
			  Func CHAR (1) NULL ,
			  Val CHAR (3) NULL ,
			  ModType CHAR (1) NULL ,
			  GroupCode CHAR (2) NULL ,
			  ModDescription VARCHAR (30) NULL ,
			  ModComment1 VARCHAR (70) NULL ,
			  ModComment2 VARCHAR (70) NULL ,
			  CreateDate DATETIME NULL ,
			  CreateUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
			  Statute VARCHAR (30) NULL ,
			  Remark1 VARCHAR (6) NULL ,
			  RemarkQualifier1 VARCHAR (2) NULL ,
			  Remark2 VARCHAR (6) NULL ,
			  RemarkQualifier2 VARCHAR (2) NULL ,
			  Remark3 VARCHAR (6) NULL ,
			  RemarkQualifier3 VARCHAR (2) NULL ,
			  Remark4 VARCHAR (6) NULL ,
			  RemarkQualifier4 VARCHAR (2) NULL ,
			  CBREReasonID INT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Modifier ADD 
     CONSTRAINT PK_Modifier PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Jurisdiction, Code, SiteCode) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Modifier ON src.Modifier   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
