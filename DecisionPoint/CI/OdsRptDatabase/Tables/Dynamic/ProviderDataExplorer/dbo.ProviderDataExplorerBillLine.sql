
IF OBJECT_ID('dbo.ProviderAnalyticsBillLine', 'U') IS NOT NULL
BEGIN
	-- Rename the existing dbo.ProviderAnalyticsBillLine tbale to dbo.ProviderDataExplorerBillLine.
	EXEC sp_rename 'dbo.ProviderAnalyticsBillLine.PK_ProviderAnalyticsBillLine', 'PK_ProviderDataExplorerBillLine', N'INDEX'
	EXEC sp_rename 'dbo.ProviderAnalyticsBillLine', 'ProviderDataExplorerBillLine'	
END
GO

IF OBJECT_ID('dbo.ProviderDataExplorerBillLine', 'U') IS NULL
			
BEGIN
CREATE TABLE dbo.ProviderDataExplorerBillLine(
	OdsPostingGroupAuditId INT NOT NULL,
	OdsCustomerId INT NOT NULL,		
	BillId INT NOT NULL,
	LineNumber INT NOT NULL,	
	OverRide SMALLINT NULL,
	DateofService DATETIME NOT NULL,
	ProcedureCode VARCHAR(13) NULL,
	Units REAL NOT NULL,	
	Charged MONEY NOT NULL,
	Allowed MONEY NOT NULL,
	Analyzed MONEY NULL,
	RefLineNo SMALLINT NULL,
	POSRevCode VARCHAR(4) NULL,	
	Adjustment MONEY NULL,
	FormType VARCHAR(10) NULL,	
	CodeType VARCHAR(25) NULL,
	Code VARCHAR(50) NULL,	
	CodeDescription VARCHAR(2500) NULL,
	Category VARCHAR(500) NULL,
	SubCategory VARCHAR(500) NULL,
	BillLineType VARCHAR(50) NOT NULL,
	BundlingFlag INT NULL,
	ExceptionFlag BIT NOT NULL DEFAULT 0,
	ExceptionComments VARCHAR(500) NULL,
	VisitType VARCHAR(100) NULL,
	BillInjuryDescription VARCHAR(100) NULL,
	ProviderZoSLat FLOAT NULL,
	ProviderZoSLong FLOAT NULL,
	ProviderZoSState VARCHAR(50) NULL,	
	ModalityType VARCHAR(100) NULL,
	ModalityUnitType VARCHAR(100) NULL,	
	RunDate DATETIME NOT NULL DEFAULT GETDATE(),	
	SubFormType VARCHAR(500) NULL,
	Modifier VARCHAR(20) NULL,
	EndNote VARCHAR(MAX) NULL

	)ON rpt_PartitionScheme(OdsCustomerId)
	WITH(
		 DATA_COMPRESSION = PAGE
		)

	ALTER TABLE dbo.ProviderDataExplorerBillLine ADD
	CONSTRAINT PK_ProviderDataExplorerBillLine PRIMARY KEY CLUSTERED
	(
		OdsPostingGroupAuditId,
		OdsCustomerId,
		BillId,
		LineNumber,
		BillLineType 
	);
END
GO

IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='DMLOperation'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerBillLine' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerBillLine DROP COLUMN DMLOperation 

END;
 
 GO
 
 
IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsCreatedDate'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerBillLine' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerBillLine DROP COLUMN OdsCreatedDate 

END;
 
 GO
  

IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsHashBytesValue'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerBillLine' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerBillLine DROP COLUMN OdsHashBytesValue 

END;
 
 GO
 
 
IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsRowisCurrent'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerBillLine' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerBillLine DROP COLUMN OdsRowisCurrent 

END;
 
 GO
  

IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsSnapshotDate'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerBillLine' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerBillLine DROP COLUMN OdsSnapshotDate 

END;
 
 GO

 IF NOT EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='Modifier'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerBillLine' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerBillLine ADD Modifier VARCHAR(20) NULL

END;
 
 GO
 
IF NOT EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='EndNote'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerBillLine' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerBillLine ADD EndNote VARCHAR(MAX) NULL

END;
 
 GO
 
 
 

