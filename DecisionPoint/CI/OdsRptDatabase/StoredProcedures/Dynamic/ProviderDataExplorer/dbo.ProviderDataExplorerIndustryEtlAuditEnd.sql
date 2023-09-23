
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerIndustryEtlAuditEnd') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerIndustryEtlAuditEnd
GO

CREATE PROCEDURE dbo.ProviderDataExplorerIndustryEtlAuditEnd(
@AuditFor VARCHAR(50),
@AuditProcess VARCHAR(50),
@ReportId INT)
AS

BEGIN
-- update the end time for the Process in Audit table
DECLARE @LastAuditId INT;

SET @LastAuditId = (
			SELECT
				MAX(AuditId)
			FROM
				dbo.ProviderDataExplorerIndustryEtlAudit
			WHERE 
				AuditFor = @AuditFor
				AND AuditProcess = @AuditProcess
				AND ReportId = @ReportId
				AND EndDatetime IS NULL
				);

UPDATE
	dbo.ProviderDataExplorerIndustryEtlAudit
SET
	EndDatetime = GETDATE(),
	UpdatedDate = GETDATE()
WHERE
	AuditId = @LastAuditId;

END


GO


