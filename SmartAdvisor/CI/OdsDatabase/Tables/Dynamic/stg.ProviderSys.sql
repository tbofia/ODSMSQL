IF OBJECT_ID('stg.ProviderSys', 'U') IS NOT NULL 
	DROP TABLE stg.ProviderSys  
BEGIN
	CREATE TABLE stg.ProviderSys
		(
		  ProviderSubset CHAR (4) NULL,
		  ProviderSubSetDesc VARCHAR (30) NULL,
		  ProviderAccess CHAR (1) NULL,
		  TaxAddrRequired CHAR (1) NULL,
		  AllowDummyProviders CHAR (1) NULL,
		  CascadeUpdatesOnImport CHAR (1) NULL,
		  RootExtIDOverrideDelimiter CHAR (1) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

