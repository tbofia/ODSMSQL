IF OBJECT_ID('src.PPONetwork', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.PPONetwork
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  PPONetworkID CHAR (2) NOT NULL ,
			  Name VARCHAR (30) NULL ,
			  TIN VARCHAR (10) NULL ,
			  Zip VARCHAR (10) NULL ,
			  State CHAR (2) NULL ,
			  City VARCHAR (15) NULL ,
			  Street VARCHAR (30) NULL ,
			  PhoneNum VARCHAR (20) NULL ,
			  PPONetworkComment VARCHAR (6000) NULL ,
			  AllowMaint CHAR (1) NULL ,
			  ReqExtPPO CHAR (1) NULL ,
			  DemoRates CHAR (1) NULL ,
			  PrintAsProvider CHAR (1) NULL ,
			  PPOType CHAR (3) NULL ,
			  PPOVersion CHAR (1) NULL ,
			  PPOBridgeExists CHAR (1) NULL ,
			  UsesDrg CHAR (1) NULL ,
			  PPOToOther CHAR (1) NULL ,
			  SubNetworkIndicator CHAR (1) NULL ,
			  EmailAddress VARCHAR (255) NULL ,
			  WebSite VARCHAR (255) NULL ,
			  BillControlSeq SMALLINT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.PPONetwork ADD 
     CONSTRAINT PK_PPONetwork PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PPONetworkID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_PPONetwork ON src.PPONetwork   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
