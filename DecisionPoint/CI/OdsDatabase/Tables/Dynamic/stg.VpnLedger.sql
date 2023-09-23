IF OBJECT_ID('stg.VpnLedger', 'U') IS NOT NULL 
	DROP TABLE stg.VpnLedger  
BEGIN
	CREATE TABLE stg.VpnLedger
		(
		  TransactionID BIGINT NULL,
		  TransactionTypeID INT NULL,
		  BillIdNo INT NULL,
		  Line_No SMALLINT NULL,
		  Charged MONEY NULL,
		  DPAllowed MONEY NULL,
		  VPNAllowed MONEY NULL,
		  Savings MONEY NULL,
		  Credits MONEY NULL,
		  HasOverride BIT NULL,
		  EndNotes NVARCHAR (200) NULL,
		  NetworkIdNo INT NULL,
		  ProcessFlag SMALLINT NULL,
		  LineType INT NULL,
		  DateTimeStamp DATETIME NULL,
		  SeqNo INT NULL,
		  VPN_Ref_Line_No SMALLINT NULL,
		  SpecialProcessing BIT NULL,
		  CreateDate DATETIME2 (7) NULL,
		  LastChangedOn DATETIME2 (7) NULL,
		  AdjustedCharged DECIMAL (19,4) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

