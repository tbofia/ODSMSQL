IF OBJECT_ID('stg.UDFLibrary', 'U') IS NOT NULL
    DROP TABLE stg.UDFLibrary;
BEGIN
    CREATE TABLE stg.UDFLibrary
        (
          UDFIdNo INT NULL ,
          UDFName VARCHAR(50) NULL ,
          ScreenType SMALLINT NULL ,
          UDFDescription VARCHAR(1000) NULL ,
          DataFormat SMALLINT NULL ,
          RequiredField SMALLINT NULL ,
          ReadOnly SMALLINT NULL ,
          Invisible SMALLINT NULL ,
          TextMaxLength SMALLINT NULL ,
          TextMask VARCHAR(50) NULL ,
          TextEnforceLength SMALLINT NULL ,
          RestrictRange SMALLINT NULL ,
          MinValDecimal REAL NULL ,
          MaxValDecimal REAL NULL ,
          MinValDate DATETIME NULL ,
          MaxValDate DATETIME NULL ,
          ListAllowMultiple SMALLINT NULL ,
          DefaultValueText VARCHAR(100) NULL ,
          DefaultValueDecimal REAL NULL ,
          DefaultValueDate DATETIME NULL ,
          UseDefault SMALLINT NULL ,
          ReqOnSubmit SMALLINT NULL ,
          IncludeDateButton BIT NULL ,
		  DmlOperation CHAR(1) NOT NULL
        );
END
GO

