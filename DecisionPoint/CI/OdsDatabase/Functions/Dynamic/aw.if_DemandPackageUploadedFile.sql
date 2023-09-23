IF OBJECT_ID('aw.if_DemandPackageUploadedFile', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_DemandPackageUploadedFile;
GO

CREATE FUNCTION aw.if_DemandPackageUploadedFile(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.DemandPackageUploadedFileId,
	t.DemandPackageId,
	t.FileName,
	t.Size,
	t.DocStoreId
FROM src.DemandPackageUploadedFile t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DemandPackageUploadedFileId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.DemandPackageUploadedFile
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DemandPackageUploadedFileId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DemandPackageUploadedFileId = s.DemandPackageUploadedFileId
WHERE t.DmlOperation <> 'D';

GO


