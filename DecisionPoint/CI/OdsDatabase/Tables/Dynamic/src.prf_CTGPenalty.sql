IF OBJECT_ID('src.prf_CTGPenalty', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.prf_CTGPenalty
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  CTGPenID INT NOT NULL ,
			  ProfileId INT NULL ,
			  ApplyPreCerts SMALLINT NULL ,
			  NoPrecertLogged SMALLINT NULL ,
			  MaxTotalPenalty SMALLINT NULL ,
			  TurnTimeForAppeals SMALLINT NULL ,
			  ApplyEndnoteForPercert SMALLINT NULL ,
			  ApplyEndnoteForCarePath SMALLINT NULL ,
			  ExemptPrecertPenalty SMALLINT NULL ,
			  ApplyNetworkPenalty BIT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.prf_CTGPenalty ADD 
     CONSTRAINT PK_prf_CTGPenalty PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CTGPenID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_prf_CTGPenalty ON src.prf_CTGPenalty   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
