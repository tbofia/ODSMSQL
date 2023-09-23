IF OBJECT_ID('stg.prf_CTGPenaltyLines', 'U') IS NOT NULL 
	DROP TABLE stg.prf_CTGPenaltyLines  
BEGIN
	CREATE TABLE stg.prf_CTGPenaltyLines
		(
		  CTGPenLineID INT NULL,
		  ProfileId INT NULL,
		  PenaltyType SMALLINT NULL,
		  FeeSchedulePercent SMALLINT NULL,
		  StartDate DATETIME NULL,
		  EndDate DATETIME NULL,
		  TurnAroundTime SMALLINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

