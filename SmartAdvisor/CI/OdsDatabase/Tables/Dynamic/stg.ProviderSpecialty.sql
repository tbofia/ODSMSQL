IF OBJECT_ID('stg.ProviderSpecialty', 'U') IS NOT NULL 
	DROP TABLE stg.ProviderSpecialty  
BEGIN
	CREATE TABLE stg.ProviderSpecialty
		(
		  Id UNIQUEIDENTIFIER NULL,
		  Description NVARCHAR (MAX) NULL,
		  ImplementationDate SMALLDATETIME NULL,
		  DeactivationDate SMALLDATETIME NULL,
		  DataSource UNIQUEIDENTIFIER NULL,
		  Creator NVARCHAR (128) NULL,
		  CreateDate SMALLDATETIME NULL,
		  LastUpdater NVARCHAR (128) NULL,
		  LastUpdateDate SMALLDATETIME NULL,
		  CbrCode NVARCHAR (4) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

