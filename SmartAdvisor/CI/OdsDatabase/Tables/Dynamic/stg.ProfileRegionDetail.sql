IF OBJECT_ID('stg.ProfileRegionDetail', 'U') IS NOT NULL 
	DROP TABLE stg.ProfileRegionDetail  
BEGIN
	CREATE TABLE stg.ProfileRegionDetail
		(
		  ProfileRegionSiteCode CHAR (3) NULL,
		  ProfileRegionID INT NULL,
		  ZipCodeFrom CHAR (5) NULL,
		  ZipCodeTo CHAR (5) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

