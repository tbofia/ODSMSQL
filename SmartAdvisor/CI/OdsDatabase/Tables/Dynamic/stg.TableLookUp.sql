IF OBJECT_ID('stg.TableLookUp', 'U') IS NOT NULL
DROP TABLE stg.TableLookUp
BEGIN
	CREATE TABLE stg.TableLookUp (
	   TableCode CHAR(4) NOT NULL,
       TypeCode CHAR(4) NOT NULL,
       Code CHAR(12) NOT NULL,
       SiteCode CHAR(3) NOT NULL,
       OldCode VARCHAR(12) NULL,
       ShortDesc VARCHAR(40) NULL,
       Source CHAR(1) NULL,
       Priority SMALLINT NULL,
       LongDesc VARCHAR(6000) NULL,
       OwnerApp CHAR(1) NULL,
       RecordStatus CHAR(1) NULL,
	   CreateDate DATETIME NULL,
	   CreateUserID CHAR(2) NULL,
	   ModDate DATETIME NULL,
	   ModUserID VARCHAR(2) NULL,
	   DmlOperation CHAR(1) NOT NULL
		)
END
GO
