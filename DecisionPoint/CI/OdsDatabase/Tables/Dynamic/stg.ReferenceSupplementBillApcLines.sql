
IF OBJECT_ID('stg.ReferenceSupplementBillApcLines', 'U') IS NOT NULL
	DROP TABLE stg.ReferenceSupplementBillApcLines

BEGIN
	CREATE TABLE stg.ReferenceSupplementBillApcLines (	
		BillIdNo INT NULL,
		SeqNo SMALLINT NULL,
		Line_No SMALLINT NULL,
		PaymentAPC VARCHAR(5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		ServiceIndicator VARCHAR(2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		PaymentIndicator VARCHAR(1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		OutlierAmount DECIMAL(19,4) NULL,
		PricerAllowed DECIMAL(19,4) NULL,
		MedicareAmount DECIMAL(19,4) NULL,
		DmlOperation CHAR(1) NOT NULL 
		)
END

GO
