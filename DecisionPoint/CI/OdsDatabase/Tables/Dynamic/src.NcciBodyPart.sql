IF OBJECT_ID('src.NcciBodyPart', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.NcciBodyPart
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  NcciBodyPartId TINYINT NOT NULL ,
			  Description VARCHAR (100) NULL ,
			  NarrativeInformation VARCHAR (MAX) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.NcciBodyPart ADD 
     CONSTRAINT PK_NcciBodyPart PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, NcciBodyPartId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_NcciBodyPart ON src.NcciBodyPart   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
