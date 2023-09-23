IF OBJECT_ID('stg.DemandPackageRequestedService', 'U') IS NOT NULL
DROP TABLE stg.DemandPackageRequestedService
BEGIN
	CREATE TABLE stg.DemandPackageRequestedService (
		DemandPackageRequestedServiceId int NULL
	   ,DemandPackageId int NULL
	   ,ReviewRequestOptions nvarchar(max) NULL
	   ,DmlOperation CHAR(1) NOT NULL
		)
END
GO
