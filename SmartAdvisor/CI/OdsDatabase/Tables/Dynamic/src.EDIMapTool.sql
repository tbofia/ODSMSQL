IF OBJECT_ID('src.EDIMapTool', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.EDIMapTool
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  SiteCode CHAR (3) NOT NULL ,
			  EDIPortType CHAR (1) NOT NULL ,
			  EDIMapToolID INT NOT NULL ,
			  EDISourceID VARCHAR (2) NULL ,
			  EDIMapToolName VARCHAR (50) NULL ,
			  EDIMapToolType VARCHAR (4) NULL ,
			  EDIMapToolDesc VARCHAR (50) NULL ,
			  EDIObjectID INT NULL ,
			  MenuTitle VARCHAR (50) NULL ,
			  SecurityLevel INT NULL ,
			  EDIInputFileName VARCHAR (50) NULL ,
			  EDIOutputFileName VARCHAR (50) NULL ,
			  EDIMultiFiles CHAR (1) NULL ,
			  EDIReportType SMALLINT NULL ,
			  FormProperties VARCHAR (MAX) NULL ,
			  Jurisdiction CHAR (2) NULL ,
			  EDIType CHAR (1) NULL ,
			  EDIPartnerID CHAR (3) NULL ,
			  BillControlTableCode CHAR (4) NULL ,
			  EDIControlFlag CHAR (1) NULL ,
			  BillControlSeq SMALLINT NULL ,
			  EDIObjectSiteCode CHAR (3) NULL ,
			  PermitUndefinedRecIDs CHAR (1) NULL ,
			  SelectionQuery VARCHAR (255) NULL ,
			  ReportSelectionQuery VARCHAR (255) NULL ,
			  Class VARCHAR (4) NULL ,
			  LineSelectionQuery VARCHAR (255) NULL ,
			  PortProperties VARCHAR (MAX) NULL ,
			  EDIFileConfigSiteCode CHAR (3) NULL ,
			  EDIFileConfigSeq INT NULL ,
			  LZControlTableCode CHAR (4) NULL ,
			  LZControlSeq SMALLINT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.EDIMapTool ADD 
     CONSTRAINT PK_EDIMapTool PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, SiteCode, EDIPortType, EDIMapToolID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_EDIMapTool ON src.EDIMapTool   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
