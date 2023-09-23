IF OBJECT_ID('src.Insurer', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Insurer
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  InsurerType CHAR (1) NOT NULL ,
			  InsurerSeq INT NOT NULL ,
			  Jurisdiction CHAR (2) NULL ,
			  StateID VARCHAR (30) NULL ,
			  TIN VARCHAR (9) NULL ,
			  AltID VARCHAR (18) NULL ,
			  Name VARCHAR (30) NULL ,
			  Address1 VARCHAR (30) NULL ,
			  Address2 VARCHAR (30) NULL ,
			  City VARCHAR (20) NULL ,
			  State CHAR (2) NULL ,
			  Zip VARCHAR (9) NULL ,
			  PhoneNum VARCHAR (20) NULL ,
			  CreateUserID CHAR (2) NULL ,
			  CreateDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  FaxNum VARCHAR (20) NULL ,
			  NAICCoCode VARCHAR (6) NULL ,
			  NAICGpCode VARCHAR (30) NULL ,
			  NCCICarrierCode VARCHAR (5) NULL ,
			  NCCIGroupCode VARCHAR (5) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Insurer ADD 
     CONSTRAINT PK_Insurer PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, InsurerType, InsurerSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Insurer ON src.Insurer   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
