IF OBJECT_ID('stg.BillFee', 'U') IS NOT NULL 
	DROP TABLE stg.BillFee  
BEGIN
	CREATE TABLE stg.BillFee
		(
		  ClientCode CHAR (4) NULL,
		  BillSeq INT NULL,
		  FeeType CHAR (1) NULL,
		  TransactionType CHAR (6) NULL,
		  FeeCtrlSource CHAR (1) NULL,
		  FeeControlSeq INT NULL,
		  FeeAmount MONEY NULL,
		  InvoiceSeq BIGINT NULL,
		  InvoiceSubSeq SMALLINT NULL,
		  PPONetworkID CHAR (2) NULL,
		  ReductionCode SMALLINT NULL,
		  FeeOverride CHAR (1) NULL,
		  OverrideVerified CHAR (1) NULL,
		  ExclusiveFee CHAR (1) NULL,
		  FeeSourceID VARCHAR (20) NULL,
		  HandlingFee CHAR (1) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

