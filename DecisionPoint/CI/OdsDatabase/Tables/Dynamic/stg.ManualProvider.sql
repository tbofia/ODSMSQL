IF OBJECT_ID('stg.ManualProvider', 'U') IS NOT NULL 
	DROP TABLE stg.ManualProvider  
BEGIN
	CREATE TABLE stg.ManualProvider
		(
		  ManualProviderId INT NULL,
		  TIN VARCHAR (15) NULL,
		  LastName VARCHAR (60) NULL,
		  FirstName VARCHAR (35) NULL,
		  GroupName VARCHAR (60) NULL,
		  Address1 VARCHAR (55) NULL,
		  Address2 VARCHAR (55) NULL,
		  City VARCHAR (30) NULL,
		  State VARCHAR (2) NULL,
		  Zip VARCHAR (12) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

