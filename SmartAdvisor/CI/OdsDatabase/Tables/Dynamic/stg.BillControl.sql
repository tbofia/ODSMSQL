IF OBJECT_ID('stg.BillControl', 'U') IS NOT NULL
DROP TABLE stg.BillControl
BEGIN
	CREATE TABLE stg.BillControl (
	   ClientCode CHAR(4) NOT NULL
	   ,BillSeq INT NOT NULL
	   ,BillControlSeq SMALLINT NOT NULL
	   ,ModDate DATETIME NULL
	   ,CreateDate DATETIME NULL
	   ,Control CHAR(1) NULL
	   ,ExternalID VARCHAR(50) NULL
	   ,BatchNumber BIGINT NULL
	   ,ModUserID CHAR(2) NULL
	   ,ExternalID2 VARCHAR(50) NULL
	   ,Message VARCHAR(500) NULL
	   ,DmlOperation CHAR(1) NOT NULL
		)
END
GO
