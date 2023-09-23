IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderAnalyticsInitialLoadPrep') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderAnalyticsInitialLoadPrep
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerInitialLoadPrep') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerInitialLoadPrep
GO

CREATE PROCEDURE dbo.ProviderDataExplorerInitialLoadPrep (@IsIncrementalLoad INT,@ReportId INT)  
AS  
BEGIN  
-- If full load then Initialize the Start Date for DateLoss
IF (@IsIncrementalLoad = 0)  
BEGIN  

  /*Update Start date of the Report in adm.Reportparameter table. */
 UPDATE  
   epsd  
 SET  
   ParameterValue = CONVERT(VARCHAR(25),DATEADD(MONTH,(-1*epgb.ParameterValue),DATEADD(month, DATEDIFF(month, -1 , getdate()) - 1, 0)),110)  
 FROM  
  adm.ReportParameters epsd  
  JOIN adm.ReportParameters epgb ON epsd.ParameterName = 'ODSPAStartDate' AND epsd.ReportId = @ReportId
              AND epgb.ParameterName = 'ODSPAGobackby' AND epgb.ReportId = @ReportId;

/*Update Enddate of the Report in adm.Reportparameter table. */
UPDATE  adm.reportparameters
		SET ParameterValue = DATEADD(MONTH,DATEDIFF(MONTH,-1,GETDATE())-1,-1)  
	WHERE ParameterName = 'ODSPAEndDate' AND ReportId = @ReportId

	  
DECLARE @TruncateFlag INT;
SELECT @TruncateFlag = ParameterValue FROM  adm.ReportParameters WHERE ReportId = @ReportId and ParameterName ='InitialLoadTruncateFlag'

DECLARE  @ReportName VARCHAR(255)
		,@SQLScript NVARCHAR(MAX)
		,@TrackingTable VARCHAR(255)
		,@IsResumed INT	
		
-- Get report Name
SET @SQLScript = 'SELECT @ReportName = RTRIM(LTRIM(REPLACE(ReportJobName,''RPT:'',''''))) FROM adm.ReportJob WHERE ReportID = '+CAST(@ReportId AS VARCHAR(3));
EXEC sp_executesql @SQLScript,N'@ReportName VARCHAR(255) OUT',@ReportName OUT;

-- Get Tracking table Name
SELECT 
	@TrackingTable = TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE='BASE TABLE'
	AND TABLE_NAME LIKE REPLACE(@ReportName,' ','_')+'_Tracking%';

-----Get the status of the track table 0-New Load 1-Incomplete Load
SET @SQLScript = 'SELECT @IsResumed = MAX(IsCustomerDone) FROM stg.'+@TrackingTable+' WHERE IsCustomerDone = 1'
EXEC sp_executesql @SQLScript,N'@IsResumed INT OUT',@IsResumed OUT


/* Get customerId for partially loaded customer in case of job restart.*/
DECLARE @Script NVARCHAR(MAX)
DECLARE @CustomerId INT
SET @Script = 'SELECT @CustomerId = OdsCustomerId  FROM stg.'+@TrackingTable+' WHERE IsCustomerDone = 0'
EXEC sp_executesql @Script,N'@CustomerId INT OUT',@CustomerId OUT

/* Delete records of partially loaded customer in case of job restart.*/
IF( @CustomerId <> 0)
BEGIN

DELETE FROM dbo.ProviderDataExplorerClaimantHeader
	   WHERE OdsCustomerId = @CustomerId;
DELETE FROM dbo.ProviderDataExplorerProvider
	   WHERE OdsCustomerId = @CustomerId;
DELETE FROM dbo.ProviderDataExplorerBillHeader
	   WHERE OdsCustomerId = @CustomerId;
DELETE FROM dbo.ProviderDataExplorerBillLine
	   WHERE OdsCustomerId = @CustomerId;

END

-- If full load then Truncate the tables
	IF (@TruncateFlag = 1 AND ISNULL(@IsResumed,0) = 0)  
	BEGIN  

		 TRUNCATE TABLE dbo.ProviderDataExplorerClaimantHeader;  
		 TRUNCATE TABLE dbo.ProviderDataExplorerProvider;  
		 TRUNCATE TABLE dbo.ProviderDataExplorerBillHeader;  
		 TRUNCATE TABLE dbo.ProviderDataExplorerBillLine;  
  
	END

  
END  
  
END  
    
    
  
GO



