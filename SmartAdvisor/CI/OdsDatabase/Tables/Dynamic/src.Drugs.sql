IF OBJECT_ID('src.Drugs', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Drugs
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  DrugCode CHAR (4) NOT NULL ,
			  DrugsDescription VARCHAR (20) NULL ,
			  Disp VARCHAR (20) NULL ,
			  DrugType CHAR (1) NULL ,
			  Cat CHAR (1) NULL ,
			  UpdateFlag CHAR (1) NULL ,
			  Uv INT NULL ,
			  CreateDate DATETIME NULL ,
			  CreateUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Drugs ADD 
     CONSTRAINT PK_Drugs PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, DrugCode) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Drugs ON src.Drugs   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
