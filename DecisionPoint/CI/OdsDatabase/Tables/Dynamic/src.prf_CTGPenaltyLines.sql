IF OBJECT_ID('src.prf_CTGPenaltyLines', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.prf_CTGPenaltyLines
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  CTGPenLineID INT NOT NULL ,
			  ProfileId INT NULL ,
			  PenaltyType SMALLINT NULL ,
			  FeeSchedulePercent SMALLINT NULL ,
			  StartDate DATETIME NULL ,
			  EndDate DATETIME NULL ,
			  TurnAroundTime SMALLINT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.prf_CTGPenaltyLines ADD 
     CONSTRAINT PK_prf_CTGPenaltyLines PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CTGPenLineID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_prf_CTGPenaltyLines ON src.prf_CTGPenaltyLines   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
