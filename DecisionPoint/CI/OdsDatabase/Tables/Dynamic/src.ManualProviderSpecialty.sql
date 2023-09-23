IF OBJECT_ID('src.ManualProviderSpecialty', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ManualProviderSpecialty
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ManualProviderId INT NOT NULL ,
			  Specialty VARCHAR (12) NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ManualProviderSpecialty ADD 
     CONSTRAINT PK_ManualProviderSpecialty PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ManualProviderId, Specialty) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ManualProviderSpecialty ON src.ManualProviderSpecialty   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
