IF OBJECT_ID('src.CriticalAccessHospitalInpatientRevenueCode', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.CriticalAccessHospitalInpatientRevenueCode
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  RevenueCode VARCHAR (4) NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.CriticalAccessHospitalInpatientRevenueCode ADD 
     CONSTRAINT PK_CriticalAccessHospitalInpatientRevenueCode PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, RevenueCode) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_CriticalAccessHospitalInpatientRevenueCode ON src.CriticalAccessHospitalInpatientRevenueCode   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
