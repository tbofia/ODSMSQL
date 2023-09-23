IF OBJECT_ID('src.ManualProvider', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ManualProvider
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ManualProviderId INT NOT NULL ,
			  TIN VARCHAR (15) NULL ,
			  LastName VARCHAR (60) NULL ,
			  FirstName VARCHAR (35) NULL ,
			  GroupName VARCHAR (60) NULL ,
			  Address1 VARCHAR (55) NULL ,
			  Address2 VARCHAR (55) NULL ,
			  City VARCHAR (30) NULL ,
			  State VARCHAR (2) NULL ,
			  Zip VARCHAR (12) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ManualProvider ADD 
     CONSTRAINT PK_ManualProvider PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ManualProviderId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ManualProvider ON src.ManualProvider   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
