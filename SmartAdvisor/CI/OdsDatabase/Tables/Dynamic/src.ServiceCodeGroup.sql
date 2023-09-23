IF OBJECT_ID('src.ServiceCodeGroup', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ServiceCodeGroup
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  SiteCode CHAR (3) NOT NULL ,
			  GroupType VARCHAR (8) NOT NULL ,
			  Family VARCHAR (8) NOT NULL ,
			  Revision CHAR (4) NOT NULL ,
			  GroupCode VARCHAR (8) NOT NULL ,
			  CodeOrder INT NOT NULL ,
			  ServiceCode VARCHAR (12) NOT NULL ,
			  ServiceCodeType VARCHAR (8) NULL ,
			  LinkGroupType VARCHAR (8) NULL ,
			  LinkGroupFamily VARCHAR (8) NULL ,
			  CodeLevel SMALLINT NULL ,
			  GlobalPriority INT NULL ,
			  Active CHAR (1) NULL ,
			  Comment VARCHAR (2000) NULL ,
			  CustomParameters VARCHAR (4000) NULL ,
			  CreateDate DATETIME NULL ,
			  CreateUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ServiceCodeGroup ADD 
     CONSTRAINT PK_ServiceCodeGroup PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, SiteCode, GroupType, Family, Revision, GroupCode, CodeOrder, ServiceCode) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ServiceCodeGroup ON src.ServiceCodeGroup   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
