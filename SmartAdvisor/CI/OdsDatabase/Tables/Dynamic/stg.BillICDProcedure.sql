IF OBJECT_ID('stg.BillICDProcedure', 'U') IS NOT NULL 
	DROP TABLE stg.BillICDProcedure  
BEGIN
	CREATE TABLE stg.BillICDProcedure
		(
		  ClientCode CHAR (4) NULL,
		  BillSeq INT NULL,
		  BillProcedureSeq SMALLINT NULL,
		  ICDProcedureID INT NULL,
		  CodeDate DATETIME NULL,
		  BilledICDProcedure CHAR (8) NULL,
		  ICDBillUsageTypeID SMALLINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

