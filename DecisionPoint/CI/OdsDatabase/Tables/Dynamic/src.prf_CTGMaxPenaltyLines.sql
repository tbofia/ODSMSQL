IF OBJECT_ID('src.prf_CTGMaxPenaltyLines', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.prf_CTGMaxPenaltyLines
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  CTGMaxPenLineID INT NOT NULL ,
			  ProfileId INT NULL ,
			  DatesBasedOn SMALLINT NULL ,
			  MaxPenaltyPercent SMALLINT NULL ,
			  StartDate DATETIME NULL ,
			  EndDate DATETIME NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.prf_CTGMaxPenaltyLines ADD 
     CONSTRAINT PK_prf_CTGMaxPenaltyLines PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CTGMaxPenLineID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_prf_CTGMaxPenaltyLines ON src.prf_CTGMaxPenaltyLines   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
