IF OBJECT_ID('src.PractitionerChild', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.PractitionerChild
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  SiteCode CHAR (3) NOT NULL ,
			  NPI VARCHAR (10) NOT NULL ,
			  Qualifier CHAR (2) NOT NULL ,
			  IssuingState CHAR (2) NOT NULL ,
			  SubSeq SMALLINT NOT NULL ,
			  SecondaryID VARCHAR (30) NULL ,
			  CreateDate DATETIME NULL ,
			  CreateUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.PractitionerChild ADD 
     CONSTRAINT PK_PractitionerChild PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, SiteCode, NPI, Qualifier, IssuingState, SubSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_PractitionerChild ON src.PractitionerChild   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
