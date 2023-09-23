IF OBJECT_ID('src.ProviderAddress', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ProviderAddress
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ProviderSubSet CHAR (4) NOT NULL ,
			  ProviderAddressSeq INT NOT NULL ,
			  RecType CHAR (2) NULL ,
			  Address1 VARCHAR (30) NULL ,
			  Address2 VARCHAR (30) NULL ,
			  City VARCHAR (30) NULL ,
			  State CHAR (2) NULL ,
			  Zip VARCHAR (9) NULL ,
			  PhoneNum VARCHAR (20) NULL ,
			  FaxNum VARCHAR (20) NULL ,
			  ContactFirstName VARCHAR (20) NULL ,
			  ContactLastName VARCHAR (20) NULL ,
			  ContactMiddleInitial CHAR (1) NULL ,
			  URFirstName VARCHAR (20) NULL ,
			  URLastName VARCHAR (20) NULL ,
			  URMiddleInitial CHAR (1) NULL ,
			  FacilityName VARCHAR (30) NULL ,
			  CountryCode CHAR (3) NULL ,
			  MailCode VARCHAR (20) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ProviderAddress ADD 
     CONSTRAINT PK_ProviderAddress PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProviderSubSet, ProviderAddressSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ProviderAddress ON src.ProviderAddress   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
