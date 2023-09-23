IF OBJECT_ID('adm.Mnt_SendNotification', 'P') IS NOT NULL
    DROP PROCEDURE adm.Mnt_SendNotification
GO
CREATE PROCEDURE adm.Mnt_SendNotification(
@Rundate DATETIME,
@ReportURL VARCHAR(MAX),
@recipients_param VARCHAR(100))
AS
BEGIN
-- DECLARE @ReportURL VARCHAR(MAX) = '',@recipients_param VARCHAR(100) = 'theodore.bofia@mitchell.com',@Rundate DATETIME = '02/11/2019';
DECLARE @SnapshotDate VARCHAR(12) = CONVERT(VARCHAR(10),@Rundate,101);
DECLARE  
		 @StatusList VARCHAR(MAX)
		,@ReconciliationCustomers VARCHAR(MAX)
		,@NoOfActiveCustomers INT
		,@NoCustomerLoadedDaily INT
		,@NoOfCompletedCustomers INT
		,@NoOfCompletePostingGroups INT
		,@NoOfCustomersWithNoFileDumps INT
		,@NoOfCustomersWithFailedLoads INT;

DECLARE @tableHTML  NVARCHAR(MAX);

DECLARE @EmailHeader VARCHAR(1000) = 
	N'	<B><H1><font FONT FACE="VERDANA" SIZE=4 color="#154360">Header1Text</font></H1></B>
		<H2><font face="VERDANA" size= 2 color = "000080">Header2Text</font></H2> '
DECLARE @EmailFooter VARCHAR(1000) =N'<br><br><FONT FACE="VERDANA" SIZE=1 COLOR="BLUE">***************** This is an auto generated mail. Please do not reply *****************</FONT>';
	    
DECLARE @EmailStyle VARCHAR(MAX) = '<style type="text/css">  #box-table  {  font-family:"Palatino Linotype", "Lucida Sans Unicode", "Lucida Grande", Sans-Serif;  font-size: 12px; }  #box-table th  {  font-family:"VERDANA"  font-size: 13px;  font-weight: normal;  background: "#8E44AD";  color: #fff;    }  #box-table td  {  color: black;  }  tr:nth-child(odd) { background-color:#CCCCCC; }  tr:nth-child(even) { background-color:#FFFFFF; }   </style>';

BEGIN
	

SELECT  
	 @NoOfActiveCustomers = S.NoOfCustomersWithCompletedFullLoads
	,@NoCustomerLoadedDaily = COUNT(DISTINCT CASE WHEN C.IsLoadedDaily = 1 THEN B.CustomerId END)
	,@NoOfCompletedCustomers = COUNT(DISTINCT CASE WHEN B.CmpltOltpPostingGroupAuditId IS NOT NULL THEN B.CustomerId END)
	,@NoOfCompletePostingGroups = S.NoOfCompletePostingGroups
	,@NoOfCustomersWithNoFileDumps = COUNT(DISTINCT CASE WHEN IsFullLoadCompleted = 1 AND InCmpltOltpPostingGroupAuditId IS NULL AND CmpltOltpPostingGroupAuditId IS NULL AND C.IsLoadedDaily != 0 THEN B.CustomerId END)
	,@NoOfCustomersWithFailedLoads = COUNT(DISTINCT CASE WHEN IsFullLoadCompleted = 1 AND InCmpltOltpPostingGroupAuditId IS NOT NULL AND CmpltOltpPostingGroupAuditId IS NULL THEN B.CustomerId END) 

FROM dbo.ETL_completionstatus S
INNER JOIN dbo.ETL_completionstatusbaseline B
	ON S.ETLLoadDate = B.SnapshotDate
INNER JOIN adm.Customer C
	ON C.CustomerId = B.CustomerId
WHERE S.ETLLoadDate = @SnapshotDate
GROUP BY S.NoOfCustomersWithCompletedFullLoads,S.NoOfCompletePostingGroups

-- Get Status For Customers Not Loaded Daily
SELECT 
	@StatusList = COALESCE(@StatusList+', ','')+CustomerName+' '+CONVERT(VARCHAR(10),MAX(P.SnapshotCreateDate),101)+' <b>('+CASE WHEN MAX(P.Status) = 'FI' THEN MAX(P.Status) ELSE '<font color="Red">'+MAX(P.Status)+'</font>' END+')</b>'

FROM adm.Customer C
INNER JOIN adm.PostingGroupAudit P
ON C.CustomerId = P.CustomerId
WHERE C.IsActive = 1
	AND C.IsLoadedDaily = 0
GROUP BY CustomerName
ORDER BY CustomerName;

-- Get List Of Customers that need reconciliation
SELECT @ReconciliationCustomers = COALESCE(@ReconciliationCustomers+', ','')+S.CustomerName
FROM(SELECT DISTINCT PGA.CustomerName
	FROM adm.ProcessAudit PA
	INNER JOIN (
		SELECT MAX(PGA.PostingGroupAuditId) MaxPostingGroupAuditId
			  ,PGA.CustomerId
			  ,C.CustomerName
		FROM adm.PostingGroupAudit PGA
		INNER JOIN adm.Customer C
		ON PGA.CustomerId = C.CustomerId
		WHERE PGA.Status = 'FI'
			AND C.IsActive = 1
		GROUP BY PGA.CustomerId,C.CustomerName) PGA
	ON PA.PostingGroupAuditId = PGA.MaxPostingGroupAuditId
	INNER JOIN adm.Process P
	ON P.ProcessId = PA.ProcessId
	AND P.IsSnapshot <> 1
	WHERE PA.TotalRecordsInSource <> PA.TotalRecordsInTarget) AS S
ORDER BY S.CustomerName

SET @tableHTML = @EmailStyle +
@EmailHeader+
    N'<table>' +
    N'<tr>'+
		N'<th><b>Summary Description </b></th>' +
		N'<th><b>Summary Value </b></th>
    </tr>' +
    N'<tr>'+
		N'<td>Active Customers</td>' +
		N'<td>'+CAST(@NoOfActiveCustomers AS VARCHAR(3))+'</td>
    </tr>' +
	N'<tr>'+
		N'<td>Customers Scheduled Daily</td>' +
		N'<td>'+CAST(@NoCustomerLoadedDaily AS VARCHAR(3))+'</td>
    </tr>' +
	N'<tr>'+
		N'<td>Customers Loaded Successfully</td>' +
		N'<td>'+CAST(@NoOfCompletedCustomers AS VARCHAR(3))+'</td>
    </tr>' +
	N'<tr>'+
		N'<td>PostingGroups Loaded Successfully</td>' +
		N'<td>'+CAST(@NoOfCompletePostingGroups AS VARCHAR(3))+'</td>
    </tr>' +
	N'<tr>'+
		N'<td>Customers With No File Dumps</td>' +
		N'<td>'+CAST(@NoOfCustomersWithNoFileDumps AS VARCHAR(3))+'</td>
    </tr>' +
	N'<tr>'+
		N'<td>Customers With Failed Loads</td>' +
		N'<td>'+CAST(@NoOfCustomersWithFailedLoads AS VARCHAR(3))+'</td>
    </tr>' +

	N'</table>'+
	N'<br><font color="#154360">Status of customers <b>NOT</b> loaded Daily: <i>'+ISNULL(@StatusList,'')+'</font></i>'+
	N'<br><br><font color="#154360">Customer[s] needing data reconciliation:</font> <i><font color="Red">'+ISNULL(@ReconciliationCustomers,'')+'</font></i>'+
@EmailFooter;

SET @tableHTML = REPLACE(@tableHTML,'<table>','<table id="box-table">');
SET @tableHTML = REPLACE(@tableHTML,'<tr>','<tr BGCOLOR="#E8DAEF">');        
SET @tableHTML = REPLACE(@tableHTML,'Header1Text','WcsOds Job Status: Run Completed.'); 
SET @tableHTML = REPLACE(@tableHTML,'<font FONT FACE="VERDANA" SIZE=4 color="000080">','<font FONT FACE="VERDANA" SIZE=4 color="006400">')
SET @tableHTML = REPLACE(@tableHTML,'Header2Text','<a href='+@ReportURL+'> View Load Statistics Reports!</a>');	
	
EXEC msdb.dbo.sp_send_dbmail @recipients= @recipients_param,
@subject = 'WcsOds Load Status Update.',
@body = @tableHTML,
@body_format = 'HTML' ;
END

END

GO
