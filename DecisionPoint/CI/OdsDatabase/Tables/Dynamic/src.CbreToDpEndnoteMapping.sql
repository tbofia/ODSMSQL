IF OBJECT_ID('src.CbreToDpEndnoteMapping', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.CbreToDpEndnoteMapping
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  Endnote INT NOT NULL ,
			  EndnoteTypeId TINYINT NOT NULL ,
			  CbreEndnote SMALLINT NOT NULL ,
			  PricingState VARCHAR (2) NOT NULL ,
			  PricingMethodId TINYINT NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.CbreToDpEndnoteMapping ADD 
     CONSTRAINT PK_CbreToDpEndnoteMapping PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Endnote, EndnoteTypeId, CbreEndnote, PricingState, PricingMethodId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_CbreToDpEndnoteMapping ON src.CbreToDpEndnoteMapping   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
