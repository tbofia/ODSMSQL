IF OBJECT_ID('adm.Mnt_SendReportNotification', 'P') IS NOT NULL
    DROP PROCEDURE adm.Mnt_SendReportNotification
GO
CREATE PROCEDURE adm.Mnt_SendReportNotification(
@ReportId INT = 0,
@SourceDatabaseName VARCHAR(50)='AcsOds',
@recipients_param VARCHAR(100))
AS
BEGIN
-- DECLARE @ReportId INT = 1,@ReportType INT = 1,@SourceDatabaseName VARCHAR(50)='AcsOds',@recipients_param VARCHAR(100) = 'theodore.bofia@mitchell.com';
DECLARE  @ReportName VARCHAR(255)
		,@spooling_job_name VARCHAR(255)
		,@CustomerName VARCHAR(255)
		,@NoOfCustomersUsedforReporting INT
		,@NoOfCustomersInReport INT
		,@SQLScript NVARCHAR(MAX)
		,@TrackingTable VARCHAR(255)
		,@OutputTableName VARCHAR(255)
		,@FilterDateColumnName VARCHAR(255)
		,@LastRunDate VARCHAR(100)
		,@LastRunDuration VARCHAR(20)
		,@Status INT = -1
		,@EmailSubject VARCHAR(255)
		,@Header1Text VARCHAR(255);

DECLARE  @SummaryTable AS TABLE (
		 OdsCustomerId INT
		,CustomerName VARCHAR(255)  
		,IsActive INT      
		,NumberOfRecords INT
		,FilterDateCutOff DATETIME
		,LastRunDate DATETIME);

-- Set Status text

DECLARE @tableHTML  NVARCHAR(MAX);
DECLARE @EmailHeader VARCHAR(1000) = 
	N'	<B><H1><font FONT FACE="VERDANA" SIZE=4 color="#154360">Header1Text</font></H1></B>
		<H2><font face="VERDANA" size= 2 color = "000080">Header2Text</font></H2> 
		<H3><font face="VERDANA" size= 2 color = "000080">Header3Text</font></H3>
		<H4><font face="VERDANA" size= 1 color = "000080">Header4Text</font></H4> '
DECLARE @EmailFooter VARCHAR(1000) =N'<br><FONT FACE="VERDANA" SIZE=1 COLOR="BLUE">***************** This is an auto generated mail. Please do not reply *****************</FONT>';
DECLARE @EmailStyle VARCHAR(MAX) = '<style type="text/css">  #box-table  {  font-family:"Palatino Linotype", "Lucida Sans Unicode", "Lucida Grande", Sans-Serif;  font-size: 12px; }  #box-table th  {  font-family:"VERDANA"  font-size: 13px;  font-weight: normal;  background: "#8E44AD";  color: #fff;    text-align: "left"; }  #box-table td  {  color: black;  }  tr:nth-child(odd) { background-color:#CCCCCC; }  tr:nth-child(even) { background-color:#FFFFFF; }   </style>';

-- Get report Name
SET @SQLScript = 'SELECT @ReportName = RTRIM(LTRIM(REPLACE(REPLACE(ReportJobName,''RPT:'',''''),''ETL:'',''''))) FROM adm.ReportJob WHERE ReportID = '+CAST(@ReportId AS VARCHAR(3));
EXEC sp_executesql @SQLScript,N'@ReportName VARCHAR(255) out',@ReportName out;

--Get Customer Report is being run for
SET	@SQLScript = '
SELECT @CustomerName = CASE WHEN C.CustomerName = ''All'' THEN ''ALL Customers'' ELSE C.CustomerName END
FROM adm.ReportJob R
INNER JOIN '+@SourceDatabaseName+'.adm.Customer C
ON CASE WHEN R.CustomerListType = -1 THEN 0 ELSE R.CustomerListType END = C.CustomerId
WHERE R.ReportId = '+CAST(@ReportId AS VARCHAR(2))

EXEC sp_executesql @SQLScript
				,N'@CustomerName VARCHAR(255) OUT'
				,@CustomerName OUT;

-- Get Tracking table Name
SELECT @TrackingTable = TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE='BASE TABLE'
	AND TABLE_NAME LIKE REPLACE(@ReportName,' ','_')+'_Tracking%';

-- Read Tracking table data
SET @SQLScript = '
SELECT @LastRunDate = CONVERT(DATE,RIGHT('''+@TrackingTable+''',8))
      ,@LastRunDuration =   RIGHT(''0'' + CAST(DATEDIFF(SS,MIN(StartTime),MAX(EndTime)) / 3600 AS VARCHAR),2) + '':'' +
							RIGHT(''0'' + CAST((DATEDIFF(SS,MIN(StartTime),MAX(EndTime)) / 60) % 60 AS VARCHAR),2) + '':'' +
							RIGHT(''0'' + CAST(DATEDIFF(SS,MIN(StartTime),MAX(EndTime)) % 60 AS VARCHAR),2)
      ,@Status = IsJobDone
FROM stg.'+@TrackingTable+'
GROUP BY IsJobDone';
EXEC sp_executesql @SQLScript
				,N'@LastRunDate VARCHAR(100) OUT,@LastRunDuration VARCHAR(20) OUT,@Status INT OUT'
				,@LastRunDate OUT,@LastRunDuration OUT,@Status OUT;

SET @EmailSubject = 'STATUS UPDATE:RPT:'+ISNULL(@ReportName,'Invalid Report')+' for '+ ISNULL(@CustomerName,'Invalid Customer');
SET @Header1Text = CASE @Status WHEN 1 THEN 'Job Status: Run Completed Successfully.' WHEN 0 THEN 'Job Status: <font color = "red">Run failed...</font>' ELSE 'Job Status: NA' END;

				
-- Get Summary information from input tables
SET @OutputTableName  = (SELECT TOP 1 TargetSchemaName+'.'+TargetTableName FROM adm.Process WHERE ReportId = @ReportId AND IsReportedOn = 1 ORDER BY ProcessId DESC)
SET @FilterDateColumnName  = (SELECT TOP 1 FilterDateColumnName FROM adm.Process WHERE ReportId = @ReportId AND IsReportedOn = 1 ORDER By ProcessId DESC)

SET	@SQLScript = '
SELECT I.OdsCustomerId
	  ,C.CustomerName
	  ,C.IsActive
      ,COUNT(I.OdsCustomerId) NumberOfRecords
	  ,MAX('+@FilterDateColumnName+') FilterDateCutOff
      ,MAX(RunDate) LastRunDate

FROM '+@SourceDatabaseName+'.adm.Customer C 
LEFT OUTER JOIN '+@OutputTableName+' I
ON I.OdsCustomerId = C.CustomerId
WHERE C.UseforReporting = 1 AND C.CustomerId <> 0
GROUP BY I.OdsCustomerId, C.CustomerName,C.IsActive'

INSERT INTO @SummaryTable EXEC (@SQLScript);

-- Get number of customers expected
SET	@SQLScript = 'SELECT @NoOfCustomersUsedforReporting  = COUNT(1) FROM '+@SourceDatabaseName+'.adm.Customer WHERE UseForReporting = 1 AND CustomerId <> 0'
EXEC sp_executesql @SQLScript
				,N'@NoOfCustomersUsedforReporting INT OUT'
				,@NoOfCustomersUsedforReporting OUT
SELECT @NoOfCustomersInReport = COUNT(1) FROM @SummaryTable WHERE OdsCustomerId IS NOT NULL
	
SET @tableHTML = @EmailStyle + @EmailHeader+
    N'<table>' +
    N'<tr>'+
		N'<th>Customer Name &nbsp</th>' +
		N'<th>Active &nbsp</th>' +
		N'<th>No. of Records Loaded &nbsp</th>' +
		N'<th>'+@FilterDateColumnName+' Cutoff &nbsp</th>' +
		N'<th>Last RunDate &nbsp</th>
    </tr>' +
    CAST ( ( SELECT td = CustomerName,'',
					td = CASE WHEN IsActive = 1 THEN 'Y' ELSE 'N' END,'',
                    td = NumberOfRecords,'',
					td = FORMAT(FilterDateCutOff,'MM/dd/yyyy'),'',
                    td = FORMAT(LastRunDate,'hh.mm tt , dd MMMM yyyy')
              FROM @SummaryTable
              ORDER BY CustomerName
              FOR XML PATH('tr'), TYPE 
    ) AS NVARCHAR(MAX) ) +
    N'</table>'+
@EmailFooter;

SET @tableHTML = REPLACE(@tableHTML,'<table>','<table id="box-table">');
SET @tableHTML = REPLACE(@tableHTML,'<tr>','<tr BGCOLOR="#E8DAEF">');        
SET @tableHTML = REPLACE(@tableHTML,'Header1Text',@Header1Text); 
SET @tableHTML = REPLACE(@tableHTML,'<font FONT FACE="VERDANA" SIZE=4 color="000080">','<font FONT FACE="VERDANA" SIZE=4 color="006400">')
SET @tableHTML = REPLACE(@tableHTML,'Header2Text','Run Duration: '+ISNULL(@LastRunDuration,'NA'));
SET @tableHTML = REPLACE(@tableHTML,'Header3Text','Run Date: '+ISNULL(@LastRunDate,'NA'));	
SET @tableHTML = REPLACE(@tableHTML,'Header4Text','No. Of Customers used for Reporting: <font size  = 2><b><i>'+CAST(@NoOfCustomersUsedforReporting AS VARCHAR(5))+'</i></b></font>. No. of Customers with data: <font size  = 2><b><i>'+CAST(@NoOfCustomersInReport AS VARCHAR(5))+'</i></b></font>');
	
EXEC msdb.dbo.sp_send_dbmail @recipients= @recipients_param,
@subject = @EmailSubject,
@body = @tableHTML,
@body_format = 'HTML' ;

-- Clean up Tracking if job was completed Succesfully
SET @SQLScript = 'DROP TABLE stg.'+@TrackingTable
IF (@Status = 1)
EXEC (@SQLScript);

-- Start Spooling for next Job
SELECT @spooling_job_name = ReportJobName FROM adm.ReportJob WHERE ReportId = 0
EXEC msdb.dbo.sp_start_job @job_name = @spooling_job_name;

END


GO


