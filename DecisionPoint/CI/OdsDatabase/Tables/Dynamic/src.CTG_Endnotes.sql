IF OBJECT_ID('src.CTG_Endnotes', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.CTG_Endnotes
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  Endnote INT NOT NULL ,
			  ShortDesc VARCHAR (50) NULL ,
			  LongDesc VARCHAR (500) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.CTG_Endnotes ADD 
     CONSTRAINT PK_CTG_Endnotes PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Endnote) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_CTG_Endnotes ON src.CTG_Endnotes   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
