
IF OBJECT_ID('stg.DemandPackageUploadedFile', 'U') IS NOT NULL
DROP TABLE stg.DemandPackageUploadedFile
BEGIN
	CREATE TABLE stg.DemandPackageUploadedFile (
		DemandPackageUploadedFileId int NULL
	   ,DemandPackageId int NULL
	   ,[FileName] varchar(255) NULL
	   ,Size int NULL
	   ,DocStoreId varchar(50) NULL
	   ,DmlOperation CHAR(1) NOT NULL
		)
END
GO


