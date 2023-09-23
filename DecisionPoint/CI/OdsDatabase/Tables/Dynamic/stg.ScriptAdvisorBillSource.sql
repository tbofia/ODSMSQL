IF OBJECT_ID('stg.ScriptAdvisorBillSource', 'U') IS NOT NULL 
	DROP TABLE stg.ScriptAdvisorBillSource  
BEGIN
	CREATE TABLE stg.ScriptAdvisorBillSource
		(
		  BillSourceId TINYINT NULL,
		  BillSource VARCHAR (15) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

