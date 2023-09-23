IF OBJECT_ID('src.Jurisdiction', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Jurisdiction
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  JurisdictionID CHAR (2) NOT NULL ,
			  Name VARCHAR (30) NULL ,
			  POSTableCode CHAR (2) NULL ,
			  TOSTableCode CHAR (2) NULL ,
			  TOBTableCode CHAR (2) NULL ,
			  ProvTypeTableCode CHAR (2) NULL ,
			  Hospital CHAR (1) NULL ,
			  ProvSpclTableCode CHAR (2) NULL ,
			  DaysToPay SMALLINT NULL ,
			  DaysToPayQualify CHAR (2) NULL ,
			  OutPatientFS CHAR (1) NULL ,
			  ProcFileVer CHAR (1) NULL ,
			  AnestUnit SMALLINT NULL ,
			  AnestRndUp SMALLINT NULL ,
			  AnestFormat CHAR (1) NULL ,
			  StateMandateSSN CHAR (1) NULL ,
			  ICDEdition SMALLINT NULL ,
			  ICD10ComplianceDate DATETIME NULL ,
			  eBillsDaysToPay SMALLINT NULL ,
			  eBillsDaysToPayQualify CHAR (2) NULL ,
			  DisputeDaysToPay SMALLINT NULL ,
			  DisputeDaysToPayQualify CHAR (2) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Jurisdiction ADD 
     CONSTRAINT PK_Jurisdiction PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, JurisdictionID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Jurisdiction ON src.Jurisdiction   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
