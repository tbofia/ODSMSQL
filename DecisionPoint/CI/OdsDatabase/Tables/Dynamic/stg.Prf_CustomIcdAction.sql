IF OBJECT_ID('stg.Prf_CustomIcdAction', 'U') IS NOT NULL 
	DROP TABLE stg.Prf_CustomIcdAction  
BEGIN
	CREATE TABLE stg.Prf_CustomIcdAction
		(
		  CustomIcdActionId INT NULL,
		  ProfileId INT NULL,
		  IcdVersionId TINYINT NULL,
		  Action SMALLINT NULL,
		  StartDate DATETIME NULL,
		  EndDate DATETIME NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

