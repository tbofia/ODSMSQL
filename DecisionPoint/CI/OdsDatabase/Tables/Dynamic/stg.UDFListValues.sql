IF OBJECT_ID('stg.UDFListValues', 'U') IS NOT NULL
    DROP TABLE stg.UDFListValues;
BEGIN
    CREATE TABLE stg.UDFListValues
        (
          ListValueIdNo INT NULL ,
          UDFIdNo INT NULL ,
          SeqNo SMALLINT NULL ,
          ListValue VARCHAR(50) NULL ,
          DefaultValue SMALLINT NULL ,
		  DmlOperation CHAR(1) NOT NULL
        );
END
GO
