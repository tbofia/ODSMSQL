IF OBJECT_ID('stg.ODGData', 'U') IS NOT NULL 
	DROP TABLE stg.ODGData  
BEGIN
	CREATE TABLE stg.ODGData
		(
		  ICDDiagnosisID INT NULL,
		  ProcedureCode VARCHAR (30) NULL,
		  ICDDescription VARCHAR (300) NULL,
		  ProcedureDescription VARCHAR (800) NULL,
		  IncidenceRate MONEY NULL,
		  ProcedureFrequency MONEY NULL,
		  Visits25Perc SMALLINT NULL,
		  Visits50Perc SMALLINT NULL,
		  Visits75Perc SMALLINT NULL,
		  VisitsMean MONEY NULL,
		  CostsMean MONEY NULL,
		  AutoApprovalCode VARCHAR (5) NULL,
		  PaymentFlag SMALLINT NULL,
		  CostPerVisit MONEY NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

