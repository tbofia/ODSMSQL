IF OBJECT_ID('stg.prf_CTGPenaltyHdr', 'U') IS NOT NULL 
	DROP TABLE stg.prf_CTGPenaltyHdr  
BEGIN
	CREATE TABLE stg.prf_CTGPenaltyHdr
		(
		  CTGPenHdrID INT NULL,
		  ProfileId INT NULL,
		  PenaltyType SMALLINT NULL,
		  PayNegRate SMALLINT NULL,
		  PayPPORate SMALLINT NULL,
		  DatesBasedOn SMALLINT NULL,
		  ApplyPenaltyToPharmacy BIT NULL,
		  ApplyPenaltyCondition BIT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

