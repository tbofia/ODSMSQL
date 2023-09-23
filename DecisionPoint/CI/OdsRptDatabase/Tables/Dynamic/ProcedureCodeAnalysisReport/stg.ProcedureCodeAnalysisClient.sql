IF OBJECT_ID('stg.ProcedureCodeAnalysisClient', 'U') IS NOT NULL
DROP TABLE stg.ProcedureCodeAnalysisClient; 
BEGIN
 CREATE TABLE stg.ProcedureCodeAnalysisClient (
	 ReportName VARCHAR(50)
	,OdsCustomerID INT
	,CoverageType VARCHAR(20)
	,FormType VARCHAR(20)
	,STATE VARCHAR(20)
	,County VARCHAR(50)
	,Company VARCHAR(100)
	,Office VARCHAR(100)
	,Year INT
	,Quarter INT
	,ProcedureCode VARCHAR(50)
	,TotalClaims INT
	,TotalClaimants INT
	,TotalCharged MONEY
	,TotalAllowed MONEY
	,TotalReductions MONEY
	,TotalBills INT
	,TotalUnits REAL
	,TotalLines INT
	)
END 
GO
