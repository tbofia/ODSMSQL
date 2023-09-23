IF OBJECT_ID('stg.DemandPackage', 'U') IS NOT NULL
DROP TABLE stg.DemandPackage
BEGIN
	CREATE TABLE stg.DemandPackage (
	   DemandPackageId int NULL
	  ,DemandClaimantId int NULL
	  ,RequestedByUserName varchar(15) NULL
	  ,DateTimeReceived datetimeoffset(7) NULL
	  ,CorrelationId varchar(36) NULL
	  ,[PageCount] smallint NULL
	  ,DmlOperation CHAR(1) NOT NULL
		)
END
GO
