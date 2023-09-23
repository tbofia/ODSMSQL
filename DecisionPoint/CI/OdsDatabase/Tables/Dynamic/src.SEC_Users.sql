IF OBJECT_ID('src.SEC_Users', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SEC_Users
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  UserId INT NOT NULL ,
			  LoginName VARCHAR (15) NULL ,
			  Password VARCHAR (30) NULL ,
			  CreatedBy VARCHAR (50) NULL ,
			  CreatedDate DATETIME NULL ,
			  UserStatus INT NULL ,
			  FirstName VARCHAR (20) NULL ,
			  LastName VARCHAR (20) NULL ,
			  AccountLocked SMALLINT NULL ,
			  LockedCounter SMALLINT NULL ,
			  PasswordCreateDate DATETIME NULL ,
			  PasswordCaseFlag SMALLINT NULL ,
			  ePassword VARCHAR (30) NULL ,
			  CurrentSettings VARCHAR (MAX) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SEC_Users ADD 
     CONSTRAINT PK_SEC_Users PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, UserId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SEC_Users ON src.SEC_Users   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
