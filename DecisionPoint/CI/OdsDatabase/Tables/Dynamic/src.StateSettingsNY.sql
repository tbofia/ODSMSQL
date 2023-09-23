IF OBJECT_ID('src.StateSettingsNY', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.StateSettingsNY
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  StateSettingsNYID INT NOT NULL ,
			  NF10PrintDate BIT NULL ,
			  NF10CheckBox1 BIT NULL ,
			  NF10CheckBox18 BIT NULL ,
			  NF10UseUnderwritingCompany BIT NULL ,
			  UnderwritingCompanyUdfId INT NULL ,
			  NaicUdfId INT NULL ,
			  DisplayNYPrintOptionsWhenZosOrSojIsNY BIT NULL ,
			  NF10DuplicatePrint BIT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.StateSettingsNY ADD 
     CONSTRAINT PK_StateSettingsNY PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, StateSettingsNYID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_StateSettingsNY ON src.StateSettingsNY   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
