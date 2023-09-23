
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderAnalyticsEtlAuditEnd') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderAnalyticsEtlAuditEnd
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerEtlAuditEnd') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerEtlAuditEnd
GO

CREATE PROCEDURE dbo.ProviderDataExplorerEtlAuditEnd(
@AuditFor VARCHAR(50),
@AuditProcess VARCHAR(50),
@AuditOdsPostingGroupAuditId INT,
@ReportId INT)
AS

BEGIN
-- update the end time for the Process in Audit table
DECLARE @LastAuditId INT;

SET @LastAuditId = (
			SELECT
				MAX(AuditId)
			FROM
				dbo.ProviderDataExplorerEtlAudit
			WHERE 
				AuditFor = @AuditFor
				AND AuditProcess = @AuditProcess
				AND DataAsOfOdsPostingGroupAuditId = ISNULL(@AuditOdsPostingGroupAuditId,0)
				AND ReportId = @ReportId
				AND EndDatetime IS NULL
				);

UPDATE
	dbo.ProviderDataExplorerEtlAudit
SET
	EndDatetime = GETDATE(),
	UpdatedDate = GETDATE()
WHERE
	AuditId = @LastAuditId;

END

GO 


