IF OBJECT_ID('stg.SEC_RightGroups', 'U') IS NOT NULL 
	DROP TABLE stg.SEC_RightGroups  
BEGIN
	CREATE TABLE stg.SEC_RightGroups
		(
		  RightGroupId INT NULL,
		  RightGroupName VARCHAR (50) NULL,
		  RightGroupDescription VARCHAR (150) NULL,
		  CreatedDate DATETIME NULL,
		  CreatedBy VARCHAR (50) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

