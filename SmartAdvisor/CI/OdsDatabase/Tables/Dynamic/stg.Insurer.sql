IF OBJECT_ID('stg.Insurer', 'U') IS NOT NULL 
	DROP TABLE stg.Insurer  
BEGIN
	CREATE TABLE stg.Insurer
		(
		  InsurerType CHAR (1) NULL,
		  InsurerSeq INT NULL,
		  Jurisdiction CHAR (2) NULL,
		  StateID VARCHAR (30) NULL,
		  TIN VARCHAR (9) NULL,
		  AltID VARCHAR (18) NULL,
		  Name VARCHAR (30) NULL,
		  Address1 VARCHAR (30) NULL,
		  Address2 VARCHAR (30) NULL,
		  City VARCHAR (20) NULL,
		  State CHAR (2) NULL,
		  Zip VARCHAR (9) NULL,
		  PhoneNum VARCHAR (20) NULL,
		  CreateUserID CHAR (2) NULL,
		  CreateDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  FaxNum VARCHAR (20) NULL,
		  NAICCoCode VARCHAR (6) NULL,
		  NAICGpCode VARCHAR (30) NULL,
		  NCCICarrierCode VARCHAR (5) NULL,
		  NCCIGroupCode VARCHAR (5) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

