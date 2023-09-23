IF OBJECT_ID('src.ClientInsurer', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ClientInsurer
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClientCode CHAR (4) NOT NULL ,
			  InsurerType CHAR (1) NOT NULL ,
			  EffectiveDate DATETIME NOT NULL ,
			  InsurerSeq INT NULL ,
			  TerminationDate DATETIME NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ClientInsurer ADD 
     CONSTRAINT PK_ClientInsurer PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, InsurerType, EffectiveDate) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ClientInsurer ON src.ClientInsurer   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
