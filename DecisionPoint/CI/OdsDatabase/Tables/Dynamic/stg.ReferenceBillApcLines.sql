
IF OBJECT_ID('stg.ReferenceBillApcLines', 'U') IS NOT NULL
	DROP TABLE stg.ReferenceBillApcLines

BEGIN
	CREATE TABLE stg.ReferenceBillApcLines
	(		
		BillIdNo INT NULL,
		Line_No SMALLINT NULL,
		PaymentAPC VARCHAR(5) NULL,
		ServiceIndicator VARCHAR(2) NULL,
		PaymentIndicator VARCHAR(1) NULL,
		OutlierAmount DECIMAL(19,4) NULL,
		PricerAllowed DECIMAL(19,4) NULL,
		MedicareAmount DECIMAL(19,4) NULL,
		DmlOperation CHAR(1) NOT NULL 
	)
END

GO
