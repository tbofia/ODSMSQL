IF OBJECT_ID('aw.DemandPackageUploadedFile', 'V') IS NOT NULL
    DROP VIEW aw.DemandPackageUploadedFile;
GO

CREATE VIEW aw.DemandPackageUploadedFile
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,DemandPackageUploadedFileId
	,DemandPackageId
	,FileName
	,Size
	,DocStoreId
FROM src.DemandPackageUploadedFile
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


