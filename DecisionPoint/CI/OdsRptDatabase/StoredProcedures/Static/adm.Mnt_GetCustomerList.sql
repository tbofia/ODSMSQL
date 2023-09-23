IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'adm.Mnt_GetCustomerList') AND type in (N'P', N'PC'))
DROP PROCEDURE adm.Mnt_GetCustomerList
GO

CREATE PROCEDURE adm.Mnt_GetCustomerList(
 @ReportId INT = 0 
,@ReportType INT = 0
,@SourceDatabaseName VARCHAR(50) = 'AcsOds'
,@CustomerListType INT = 0
)
AS
BEGIN
-- DECLARE @ReportId INT = 1 ,@ReportType INT = 1,@SourceDatabaseName VARCHAR(50) = 'AcsOds',@CustomerListType INT = -1
DECLARE  @ReportName VARCHAR(255)
		,@SQLScript NVARCHAR(MAX)
		,@TrackingTable VARCHAR(255);
		
-- Get report Name
SET @SQLScript = 'SELECT @ReportName = RTRIM(LTRIM(REPLACE(REPLACE(ReportJobName,''RPT:'',''''),''ETL:'',''''))) FROM adm.ReportJob WHERE ReportID = '+CAST(@ReportId AS VARCHAR(3));
EXEC sp_executesql @SQLScript,N'@ReportName VARCHAR(255) out',@ReportName out;

-- Get Tracking table Name
SELECT @TrackingTable = TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE='BASE TABLE'
	AND TABLE_NAME LIKE REPLACE(@ReportName,' ','_')+'_Tracking%';

-- Get List of customers to run for by crossing against tracking table	
SET @SQLScript = 
'SELECT DISTINCT C.CustomerId
 FROM '+@SourceDatabaseName+'.adm.Customer C
 INNER JOIN rpt.CustomerReportSubscription I
	ON C.CustomerId = I.CustomerId
	AND I.ReportId = '+CAST(@ReportId AS VARCHAR(5))+'
	AND I.IsActive = 1
 LEFT OUTER JOIN stg.'+@TrackingTable+' T 
	ON C.CustomerId = T.OdsCustomerId 
	AND T.ReportTypeId = '+CAST(@ReportType AS CHAR(2))+'
 WHERE C.UseForReporting = 1 
 AND(T.IsCustomerDone IS NULL OR T.IsCustomerDone = 0)
 AND C.CustomerId = CASE WHEN '+CAST(@CustomerListType AS VARCHAR(5))+' = -1 THEN C.CustomerId ELSE '+CAST(@CustomerListType AS VARCHAR(5))+' END
 '+CASE WHEN @CustomerListType = -1 THEN 'AND C.CustomerId <> 0' ELSE '' END;
 
EXEC(@SQLScript);

END
GO

 
 