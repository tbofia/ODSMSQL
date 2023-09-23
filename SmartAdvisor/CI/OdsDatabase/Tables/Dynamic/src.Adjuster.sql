IF OBJECT_ID('src.Adjuster', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Adjuster
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClaimSysSubSet CHAR (4) NOT NULL ,
			  Adjuster VARCHAR (25) NOT NULL ,
			  FirstName VARCHAR (20) NULL ,
			  LastName VARCHAR (20) NULL ,
			  MInitial CHAR (1) NULL ,
			  Title VARCHAR (20) NULL ,
			  Address1 VARCHAR (30) NULL ,
			  Address2 VARCHAR (30) NULL ,
			  City VARCHAR (20) NULL ,
			  State CHAR (2) NULL ,
			  Zip VARCHAR (9) NULL ,
			  PhoneNum VARCHAR (20) NULL ,
			  PhoneNumExt VARCHAR (10) NULL ,
			  FaxNum VARCHAR (20) NULL ,
			  Email VARCHAR (128) NULL ,
			  CreateDate DATETIME NULL ,
			  CreateUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Adjuster ADD 
     CONSTRAINT PK_Adjuster PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimSysSubSet, Adjuster) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Adjuster ON src.Adjuster   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
