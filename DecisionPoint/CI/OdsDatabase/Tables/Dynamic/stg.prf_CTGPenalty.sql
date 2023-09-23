IF OBJECT_ID('stg.prf_CTGPenalty', 'U') IS NOT NULL 
	DROP TABLE stg.prf_CTGPenalty  
BEGIN
	CREATE TABLE stg.prf_CTGPenalty
		(
		  CTGPenID INT NULL,
		  ProfileId INT NULL,
		  ApplyPreCerts SMALLINT NULL,
		  NoPrecertLogged SMALLINT NULL,
		  MaxTotalPenalty SMALLINT NULL,
		  TurnTimeForAppeals SMALLINT NULL,
		  ApplyEndnoteForPercert SMALLINT NULL,
		  ApplyEndnoteForCarePath SMALLINT NULL,
		  ExemptPrecertPenalty SMALLINT NULL,
		  ApplyNetworkPenalty BIT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

