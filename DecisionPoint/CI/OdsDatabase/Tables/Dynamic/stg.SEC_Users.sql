IF OBJECT_ID('stg.SEC_Users', 'U') IS NOT NULL 
	DROP TABLE stg.SEC_Users  
BEGIN
	CREATE TABLE stg.SEC_Users
		(
		  UserId INT NULL,
		  LoginName VARCHAR (15) NULL,
		  Password VARCHAR (30) NULL,
		  CreatedBy VARCHAR (50) NULL,
		  CreatedDate DATETIME NULL,
		  UserStatus INT NULL,
		  FirstName VARCHAR (20) NULL,
		  LastName VARCHAR (20) NULL,
		  AccountLocked SMALLINT NULL,
		  LockedCounter SMALLINT NULL,
		  PasswordCreateDate DATETIME NULL,
		  PasswordCaseFlag SMALLINT NULL,
		  ePassword VARCHAR (30) NULL,
		  CurrentSettings VARCHAR (MAX) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

