IF OBJECT_ID('stg.ClaimantManualProviderSummary', 'U') IS NOT NULL 
	DROP TABLE stg.ClaimantManualProviderSummary  
BEGIN
	CREATE TABLE stg.ClaimantManualProviderSummary
		(
		  ManualProviderId INT NULL,
		  DemandClaimantId INT NULL,
		  FirstDateOfService DATETIME2 (7) NULL,
		  LastDateOfService DATETIME2 (7) NULL,
		  Visits INT NULL,
		  ChargedAmount DECIMAL NULL,
		  EvaluatedAmount DECIMAL NULL,
		  MinimumEvaluatedAmount DECIMAL NULL,
		  MaximumEvaluatedAmount DECIMAL NULL,
		  Comments VARCHAR (255) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

