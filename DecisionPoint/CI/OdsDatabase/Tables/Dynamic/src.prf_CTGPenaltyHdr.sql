IF OBJECT_ID('src.prf_CTGPenaltyHdr', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.prf_CTGPenaltyHdr
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  CTGPenHdrID INT NOT NULL ,
			  ProfileId INT NULL ,
			  PenaltyType SMALLINT NULL ,
			  PayNegRate SMALLINT NULL ,
			  PayPPORate SMALLINT NULL ,
			  DatesBasedOn SMALLINT NULL ,
			  ApplyPenaltyToPharmacy BIT NULL ,
			  ApplyPenaltyCondition BIT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.prf_CTGPenaltyHdr ADD 
     CONSTRAINT PK_prf_CTGPenaltyHdr PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CTGPenHdrID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_prf_CTGPenaltyHdr ON src.prf_CTGPenaltyHdr   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
