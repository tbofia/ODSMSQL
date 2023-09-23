IF OBJECT_ID('stg.EDIMapTool', 'U') IS NOT NULL 
	DROP TABLE stg.EDIMapTool  
BEGIN
	CREATE TABLE stg.EDIMapTool
		(
		  SiteCode CHAR (3) NULL,
		  EDIPortType CHAR (1) NULL,
		  EDIMapToolID INT NULL,
		  EDISourceID VARCHAR (2) NULL,
		  EDIMapToolName VARCHAR (50) NULL,
		  EDIMapToolType VARCHAR (4) NULL,
		  EDIMapToolDesc VARCHAR (50) NULL,
		  EDIObjectID INT NULL,
		  MenuTitle VARCHAR (50) NULL,
		  SecurityLevel INT NULL,
		  EDIInputFileName VARCHAR (50) NULL,
		  EDIOutputFileName VARCHAR (50) NULL,
		  EDIMultiFiles CHAR (1) NULL,
		  EDIReportType SMALLINT NULL,
		  FormProperties VARCHAR (MAX) NULL,
		  Jurisdiction CHAR (2) NULL,
		  EDIType CHAR (1) NULL,
		  EDIPartnerID CHAR (3) NULL,
		  BillControlTableCode CHAR (4) NULL,
		  EDIControlFlag CHAR (1) NULL,
		  BillControlSeq SMALLINT NULL,
		  EDIObjectSiteCode CHAR (3) NULL,
		  PermitUndefinedRecIDs CHAR (1) NULL,
		  SelectionQuery VARCHAR (255) NULL,
		  ReportSelectionQuery VARCHAR (255) NULL,
		  Class VARCHAR (4) NULL,
		  LineSelectionQuery VARCHAR (255) NULL,
		  PortProperties VARCHAR (MAX) NULL,
		  EDIFileConfigSiteCode CHAR (3) NULL,
		  EDIFileConfigSeq INT NULL,
		  LZControlTableCode CHAR (4) NULL,
		  LZControlSeq SMALLINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

