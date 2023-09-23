IF OBJECT_ID('stg.Adjustor', 'U') IS NOT NULL
    DROP TABLE stg.Adjustor;
BEGIN
    CREATE TABLE stg.Adjustor
        (
          lAdjIdNo INT NULL ,
          IDNumber VARCHAR(15) NULL ,
          Lastname VARCHAR(30) NULL ,
          FirstName VARCHAR(30) NULL ,
          Address1 VARCHAR(30) NULL ,
          Address2 VARCHAR(30) NULL ,
          City VARCHAR(30) NULL ,
          State VARCHAR(2) NULL ,
          ZipCode VARCHAR(12) NULL ,
          Phone VARCHAR(25) NULL ,
          Fax VARCHAR(25) NULL ,
          Office VARCHAR(120) NULL ,
          EMail VARCHAR(60) NULL ,
          InUse VARCHAR(100) NULL ,
          OfficeIdNo INT NULL ,
          UserId INT NULL ,
          CreateDate DATETIME NULL ,
          LastChangedOn DATETIME NULL ,
		  DmlOperation CHAR(1) NOT NULL
        );
END
GO

-- Alter Office Column size to increase from 30 to 120
ALTER TABLE stg.Adjustor
ALTER COLUMN Office VARCHAR(120);
GO

