
IF OBJECT_ID('dbo.ProviderAnalyticsBillHeader', 'U') IS NOT NULL
BEGIN
	-- Rename the existing dbo.ProviderAnalyticsBillHeader tbale to dbo.ProviderDataExplorerBillHeader.
	EXEC sp_rename 'dbo.ProviderAnalyticsBillHeader.PK_ProviderAnalyticsBillHeader', 'PK_ProviderDataExplorerBillHeader', N'INDEX'
	EXEC sp_rename 'dbo.ProviderAnalyticsBillHeader', 'ProviderDataExplorerBillHeader'	
END
GO

IF OBJECT_ID('dbo.ProviderDataExplorerBillHeader', 'U') IS NULL

BEGIN
CREATE TABLE dbo.ProviderDataExplorerBillHeader
(
	OdsPostingGroupAuditId INT NOT NULL,
	OdsCustomerId INT NOT NULL,		
	BillId INT NOT NULL,
	ClaimantHeaderId INT NULL,
	DateSaved DATETIME NULL,	
	ClaimDateLoss DATETIME NULL,
	CVType VARCHAR(2) NULL,
	Flags INT NULL,	
	CreateDate DATETIME NULL,
	ProviderZipofService VARCHAR(12) NULL,
	TypeofBill VARCHAR(4) NULL,
	LastChangedOn DATETIME NULL,	
	CVTypeDescription VARCHAR(100) NULL,
	RunDate DATETIME NOT NULL DEFAULT GETDATE()	

	)ON rpt_PartitionScheme(OdsCustomerId)
	WITH
	(
      DATA_COMPRESSION = PAGE
	  )

	ALTER TABLE dbo.ProviderDataExplorerBillHeader ADD
	CONSTRAINT PK_ProviderDataExplorerBillHeader PRIMARY KEY 
	(
		OdsPostingGroupAuditId ,
		OdsCustomerId ,
		BillId				
	);

END
GO



IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='DMLOperation'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerBillHeader' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerBillHeader DROP COLUMN DMLOperation 

END;
 
 GO
 
 
IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsCreatedDate'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerBillHeader' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerBillHeader DROP COLUMN OdsCreatedDate 

END;
 
 GO
 

IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsHashBytesValue'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerBillHeader' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerBillHeader DROP COLUMN OdsHashBytesValue 

END;
 
 GO
 
 
IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsRowisCurrent'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerBillHeader' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerBillHeader DROP COLUMN OdsRowisCurrent 

END;
 
 GO
 
 
IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsSnapshotDate'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerBillHeader' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerBillHeader DROP COLUMN OdsSnapshotDate 

END;
 
 GO


 IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='Category'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerBillHeader' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerBillHeader DROP COLUMN Category 

END;
 
 GO

 
 IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='CatDesc'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerBillHeader' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerBillHeader DROP COLUMN CatDesc 

END;
 
 GO



