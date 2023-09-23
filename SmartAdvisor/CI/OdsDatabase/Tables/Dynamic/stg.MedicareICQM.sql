IF OBJECT_ID('stg.MedicareICQM', 'U') IS NOT NULL 
	DROP TABLE stg.MedicareICQM  
BEGIN
	CREATE TABLE stg.MedicareICQM
		(
		  Jurisdiction CHAR (2) NULL,
		  MdicqmSeq INT NULL,
		  ProviderNum VARCHAR (6) NULL,
		  ProvSuffix CHAR (1) NULL,
		  ServiceCode VARCHAR (25) NULL,
		  HCPCS VARCHAR (5) NULL,
		  Revenue CHAR (3) NULL,
		  MedicareICQMDescription VARCHAR (40) NULL,
		  IP1995 INT NULL,
		  OP1995 INT NULL,
		  IP1996 INT NULL,
		  OP1996 INT NULL,
		  IP1997 INT NULL,
		  OP1997 INT NULL,
		  IP1998 INT NULL,
		  OP1998 INT NULL,
		  NPI VARCHAR (10) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

