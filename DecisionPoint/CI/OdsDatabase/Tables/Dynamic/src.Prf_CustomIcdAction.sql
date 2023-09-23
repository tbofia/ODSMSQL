IF OBJECT_ID('src.Prf_CustomIcdAction', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Prf_CustomIcdAction
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  CustomIcdActionId INT NOT NULL ,
			  ProfileId INT NULL ,
			  IcdVersionId TINYINT NULL ,
			  Action SMALLINT NULL ,
			  StartDate DATETIME NULL ,
			  EndDate DATETIME NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Prf_CustomIcdAction ADD 
     CONSTRAINT PK_Prf_CustomIcdAction PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CustomIcdActionId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Prf_CustomIcdAction ON src.Prf_CustomIcdAction   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
