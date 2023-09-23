IF OBJECT_ID('stg.ProfileRegion', 'U') IS NOT NULL 
	DROP TABLE stg.ProfileRegion  
BEGIN
	CREATE TABLE stg.ProfileRegion
		(
		  SiteCode CHAR (3) NULL,
		  ProfileRegionID INT NULL,
		  RegionTypeCode CHAR (2) NULL,
		  RegionName VARCHAR (50) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

