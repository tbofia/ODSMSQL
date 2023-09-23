IF OBJECT_ID('stg.SEC_User_RightGroups', 'U') IS NOT NULL 
	DROP TABLE stg.SEC_User_RightGroups  
BEGIN
	CREATE TABLE stg.SEC_User_RightGroups
		(
		  SECUserRightGroupId INT NULL,
		  UserId INT NULL,
		  RightGroupId INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

