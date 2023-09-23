IF OBJECT_ID('stg.PPOProfileNetworks', 'U') IS NOT NULL 
	DROP TABLE stg.PPOProfileNetworks  
BEGIN
	CREATE TABLE stg.PPOProfileNetworks
		(
		  PPOProfileSiteCode CHAR (3) NULL,
		  PPOProfileID INT NULL,
		  ProfileRegionSiteCode CHAR (3) NULL,
		  ProfileRegionID INT NULL,
		  NetworkOrder SMALLINT NULL,
		  PPONetworkID CHAR (2) NULL,
		  SearchLogic CHAR (1) NULL,
		  Verification CHAR (1) NULL,
		  EffectiveDate DATETIME NULL,
		  TerminationDate DATETIME NULL,
		  JurisdictionInd CHAR (1) NULL,
		  JurisdictionInsurerSeq INT NULL,
		  JurisdictionUseOnly CHAR (1) NULL,
		  PPOSSTinReq CHAR (1) NULL,
		  PPOSSLicReq CHAR (1) NULL,
		  DefaultExtendedSearches SMALLINT NULL,
		  DefaultExtendedFilters SMALLINT NULL,
		  SeveredTies CHAR (1) NULL,
		  POS VARCHAR (500) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

