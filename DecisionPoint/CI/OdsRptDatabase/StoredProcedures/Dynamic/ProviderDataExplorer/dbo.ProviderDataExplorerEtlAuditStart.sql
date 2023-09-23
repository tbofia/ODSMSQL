IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderAnalyticsEtlAuditStart') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderAnalyticsEtlAuditStart
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerEtlAuditStart') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerEtlAuditStart
GO

CREATE PROCEDURE dbo.ProviderDataExplorerEtlAuditStart(
@AuditFor VARCHAR(50),
@AuditProcess VARCHAR(50),
@AuditOdsPostingGroupAuditId INT,
@ReportId INT)
AS
BEGIN
-- Insert the Process tracking in Audit Table
INSERT INTO dbo.ProviderDataExplorerEtlAudit(
	AuditFor,
	AuditProcess,
	DataAsOfOdsPostingGroupAuditId,
	StartDatetime,
	ReportId
	)
SELECT
	@AuditFor,
	@AuditProcess,
	ISNULL(@AuditOdsPostingGroupAuditId,0),
	GETDATE(),
	@ReportId

END

GO


