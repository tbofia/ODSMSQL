IF OBJECT_ID('stg.prf_CTGMaxPenaltyLines', 'U') IS NOT NULL 
	DROP TABLE stg.prf_CTGMaxPenaltyLines  
BEGIN
	CREATE TABLE stg.prf_CTGMaxPenaltyLines
		(
		  CTGMaxPenLineID INT NULL,
		  ProfileId INT NULL,
		  DatesBasedOn SMALLINT NULL,
		  MaxPenaltyPercent SMALLINT NULL,
		  StartDate DATETIME NULL,
		  EndDate DATETIME NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

