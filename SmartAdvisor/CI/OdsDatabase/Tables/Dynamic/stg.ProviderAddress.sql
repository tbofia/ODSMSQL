IF OBJECT_ID('stg.ProviderAddress', 'U') IS NOT NULL 
	DROP TABLE stg.ProviderAddress  
BEGIN
	CREATE TABLE stg.ProviderAddress
		(
		  ProviderSubSet CHAR (4) NULL,
		  ProviderAddressSeq INT NULL,
		  RecType CHAR (2) NULL,
		  Address1 VARCHAR (30) NULL,
		  Address2 VARCHAR (30) NULL,
		  City VARCHAR (30) NULL,
		  State CHAR (2) NULL,
		  Zip VARCHAR (9) NULL,
		  PhoneNum VARCHAR (20) NULL,
		  FaxNum VARCHAR (20) NULL,
		  ContactFirstName VARCHAR (20) NULL,
		  ContactLastName VARCHAR (20) NULL,
		  ContactMiddleInitial CHAR (1) NULL,
		  URFirstName VARCHAR (20) NULL,
		  URLastName VARCHAR (20) NULL,
		  URMiddleInitial CHAR (1) NULL,
		  FacilityName VARCHAR (30) NULL,
		  CountryCode CHAR (3) NULL,
		  MailCode VARCHAR (20) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

