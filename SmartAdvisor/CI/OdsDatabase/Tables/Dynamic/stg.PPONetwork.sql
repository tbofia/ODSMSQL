IF OBJECT_ID('stg.PPONetwork', 'U') IS NOT NULL 
	DROP TABLE stg.PPONetwork  
BEGIN
	CREATE TABLE stg.PPONetwork
		(
		  PPONetworkID CHAR (2) NULL,
		  Name VARCHAR (30) NULL,
		  TIN VARCHAR (10) NULL,
		  Zip VARCHAR (10) NULL,
		  State CHAR (2) NULL,
		  City VARCHAR (15) NULL,
		  Street VARCHAR (30) NULL,
		  PhoneNum VARCHAR (20) NULL,
		  PPONetworkComment VARCHAR (6000) NULL,
		  AllowMaint CHAR (1) NULL,
		  ReqExtPPO CHAR (1) NULL,
		  DemoRates CHAR (1) NULL,
		  PrintAsProvider CHAR (1) NULL,
		  PPOType CHAR (3) NULL,
		  PPOVersion CHAR (1) NULL,
		  PPOBridgeExists CHAR (1) NULL,
		  UsesDrg CHAR (1) NULL,
		  PPOToOther CHAR (1) NULL,
		  SubNetworkIndicator CHAR (1) NULL,
		  EmailAddress VARCHAR (255) NULL,
		  WebSite VARCHAR (255) NULL,
		  BillControlSeq SMALLINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

