
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.GetMaxRunFromOdsPostingGroupAuditId') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GetMaxRunFromOdsPostingGroupAuditId
GO

CREATE FUNCTION dbo.GetMaxRunFromOdsPostingGroupAuditId(
@ProcessName VARCHAR(100),
@AuditFor VARCHAR(100),
@ReportId INT
)  
RETURNS INT  
AS  
BEGIN  
DECLARE @DataAsOfOdsPostingGroupAuditId INT  
  
SELECT  
 @DataAsOfOdsPostingGroupAuditId=MAX(DataAsOfOdsPostingGroupAuditId)  
 FROM dbo.ProviderDataExplorerEtlAudit 
WHERE AuditFor = @AuditFor  
AND AuditProcess = @ProcessName  
AND EndDatetime IS NOT NULL  
AND ReportId = @ReportId  
  
RETURN @DataAsOfOdsPostingGroupAuditId  
  
END 
GO


 