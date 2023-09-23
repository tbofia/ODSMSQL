
IF OBJECT_ID('dbo.ProviderAnalyticsProvider', 'U') IS NOT NULL
BEGIN
	-- Rename the existing dbo.ProviderAnalyticsProvider tbale to dbo.ProviderDataExplorerProvider.
	EXEC sp_rename 'dbo.ProviderAnalyticsProvider.PK_ProviderAnalyticsProvider', 'PK_ProviderDataExplorerProvider', N'INDEX'
	EXEC sp_rename 'dbo.ProviderAnalyticsProvider', 'ProviderDataExplorerProvider'	
END

GO

IF OBJECT_ID('dbo.ProviderDataExplorerProvider', 'U') IS NULL

BEGIN
CREATE TABLE dbo.ProviderDataExplorerProvider(
	OdsPostingGroupAuditId INT NOT NULL,
	OdsCustomerId INT NOT NULL,		
	ProviderId INT NOT NULL,	
	ProviderTIN VARCHAR(15) NULL,
	ProviderFirstName VARCHAR(35) NULL,
    ProviderLastName  VARCHAR(60) NULL,	
	ProviderGroup VARCHAR(60) NULL,	
	ProviderState VARCHAR(2) NULL,
	ProviderZip VARCHAR(12) NULL,	
	ProviderSPCList VARCHAR(50) NULL,
	ProviderNPINumber VARCHAR(10) NULL,	
	ProviderName VARCHAR(150) NULL,
	ProviderTypeID VARCHAR(10) NULL,
	ProviderClusterId VARCHAR(100) NULL,
	ProviderClusterName VARCHAR(350) NULL,	
	Specialty VARCHAR(255) NULL,
	ClusterSpecialty VARCHAR(2000) NULL,
	CreatedDate DATETIME NULL,	
	RunDate DATETIME NOT NULL DEFAULT GETDATE()

	)	
	ON rpt_PartitionScheme(OdsCustomerId)
		 WITH(  
				DATA_COMPRESSION = PAGE
		 )
		
	ALTER TABLE dbo.ProviderDataExplorerProvider ADD
	CONSTRAINT PK_ProviderDataExplorerProvider PRIMARY KEY CLUSTERED
	(
		OdsPostingGroupAuditId,
		OdsCustomerId,
		ProviderId	
	);

END
GO 

IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='DMLOperation'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerProvider' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerProvider DROP COLUMN DMLOperation 

END;
 
 GO
  

IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsCreatedDate'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerProvider' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerProvider DROP COLUMN OdsCreatedDate 

END;
 
 GO
  

IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsHashBytesValue'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerProvider' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerProvider DROP COLUMN OdsHashBytesValue 

END;
 
 GO
 
 
IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsRowIsCurrent'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerProvider' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerProvider DROP COLUMN OdsRowIsCurrent 

END;
 
 GO
 
 
IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsSnapshotDate'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerProvider' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerProvider DROP COLUMN OdsSnapshotDate 

END;
 
 GO

IF NOT EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='ProviderClusterName'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerProvider' 
						AND CHARACTER_MAXIMUM_LENGTH = 350
)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerProvider ALTER COLUMN ProviderClusterName VARCHAR(350) NULL 

END;
 
 GO

 
 
IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='LastChangedOn'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerProvider' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerProvider DROP COLUMN LastChangedOn 

END;
 
 GO
 
