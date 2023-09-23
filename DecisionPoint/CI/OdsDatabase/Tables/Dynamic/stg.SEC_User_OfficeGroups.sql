IF OBJECT_ID('stg.SEC_User_OfficeGroups', 'U') IS NOT NULL 
	DROP TABLE stg.SEC_User_OfficeGroups  
BEGIN
	CREATE TABLE stg.SEC_User_OfficeGroups
		(
		  SECUserOfficeGroupId INT NULL,
		  UserId INT NULL,
		  OffcGroupId INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

