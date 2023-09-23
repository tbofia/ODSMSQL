IF OBJECT_ID('stg.prf_PPO', 'U') IS NOT NULL 
	DROP TABLE stg.prf_PPO  
BEGIN
	CREATE TABLE stg.prf_PPO
		(
		  PPOSysId INT NULL,
		  ProfileId INT NULL,
		  PPOId INT NULL,
		  bStatus SMALLINT NULL,
		  StartDate DATETIME NULL,
		  EndDate DATETIME NULL,
		  AutoSend SMALLINT NULL,
		  AutoResend SMALLINT NULL,
		  BypassMatching SMALLINT NULL,
		  UseProviderNetworkEnrollment SMALLINT NULL,
		  TieredTypeId SMALLINT NULL,
		  Priority SMALLINT NULL,
		  PolicyEffectiveDate DATETIME NULL,
		  BillFormType INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

