IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.AdjusterWorkspaceServiceRequest') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.AdjusterWorkspaceServiceRequest
GO

CREATE PROCEDURE dbo.AdjusterWorkspaceServiceRequest(
@Customer nvarchar(200))
AS
BEGIN
-- DECLARE @Customer nvarchar(200) = 'MMedical_AAAFL'
DECLARE @SQLScript VARCHAR(MAX);

SET @SQLScript = '
INSERT INTO dbo.AdjusterWorkspaceServiceRequestReport (
	Customer
	,Company
	,Office
	,SOJ
	,RequestedByUserName
	,DateTimeReceived
	,DemandClaimantId
	,DemandPackageId
	,DemandPackageRequestedServiceId
	,DemandPackageUploadedFileId
	,Size
	,FileName
	,FileCount
	,PageCount
	)
SELECT DCMNT.OrganizationId
	,ISNULL(CPNY.CompanyName, '' UNKNOWN '') Company
	,ISNULL(OFC.OfcName, '' UNKNOWN '') Office
	,CMNT.CmtStateOfJurisdiction SOJ
	,DP.RequestedByUserName Adjuster
	,CAST(DateTimeReceived AS DATE) DateReceived
	,DCMNT.DemandClaimantId
	,DP.DemandPackageId
	,DPRS.DemandPackageRequestedServiceId
	,DPF.DemandPackageUploadedFileId
	,DPF.Size
	,DPF.FileName
	,CASE WHEN DPF.DemandPackageUploadedFileId IS NULL THEN 0 ELSE 1 END
	,DP.PageCount
FROM '+@Customer+'.dm.DemandClaimant DCMNT
LEFT OUTER JOIN '+@Customer+'.dbo.CLAIMANT CMNT ON DCMNT.ExternalClaimantId = CMNT.CmtIDNo
INNER JOIN '+@Customer+'.dbo.CLAIMS CLM ON CLM.ClaimIDNo = CMNT.ClaimIDNo
INNER JOIN '+@Customer+'.dbo.prf_Office OFC ON OFC.CompanyId = CLM.CompanyID
	AND OFC.OfficeId = CLM.OfficeIndex
INNER JOIN '+@Customer+'.dbo.prf_COMPANY CPNY ON CPNY.CompanyId = OFC.CompanyId
INNER JOIN '+@Customer+'.dm.DemandPackage DP ON DCMNT.DemandClaimantId = DP.DemandClaimantId
INNER JOIN '+@Customer+'.dm.DemandPackageUploadedFile DPF ON DP.DemandPackageid = DPF.DemandPackageid
INNER JOIN '+@Customer+'.dm.DemandPackageRequestedService DPRS ON DPRS.DemandPackageId = DP.DemandPackageId; '
	
EXEC (@SQLScript);
              
END

GO

