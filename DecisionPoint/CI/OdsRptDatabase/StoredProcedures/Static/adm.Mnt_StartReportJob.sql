IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'adm.Mnt_StartReportJob') AND type IN (N'P',N'PC'))
DROP PROCEDURE adm.Mnt_StartReportJob
GO

CREATE PROCEDURE adm.Mnt_StartReportJob(
@SourceDatabaseName VARCHAR(50)='AcsOds')
AS
BEGIN
-- DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds'
DECLARE  @Job_Name VARCHAR(255)
		,@IsDataAvailable INT
		,@SQLQuery NVARCHAR(MAX);

SET @SQLQuery = '
WITH cte_CustomersNotLoadedDaily AS(
SELECT PGA.CustomerId
	,MAX(SnapshotCreateDate) LastLoadedSnapshot
FROM '+@SourceDatabaseName+'.adm.PostingGroupAudit PGA
INNER JOIN '+@SourceDatabaseName+'.adm.Customer C
ON PGA.CustomerId = C.CustomerId
WHERE C.IsLoadedDaily = 0
AND C.UseForReporting = 1
AND PGA.Status = ''FI''
GROUP BY PGA.CustomerId)
-- Count Total Cunstomer and Also Count customers with Most Recent snapshot in current month, numbers should be equal to proceed
SELECT @IsDataAvailable = 1 
FROM cte_CustomersNotLoadedDaily
HAVING COUNT(CustomerId) = COUNT(CASE WHEN MONTH(LastLoadedSnapshot) = MONTH(GETDATE()) AND YEAR(LastLoadedSnapshot) = YEAR(GETDATE()) THEN CustomerId END)'

EXEC sp_executesql  @SQLQuery,N'@IsDataAvailable INT OUT',@IsDataAvailable OUT;

-- This will return a prioritized list of jobs based on the last time they were run.
;WITH cte_ReportJobList AS(
SELECT R.ReportId
	  ,R.ReportJobName
      ,R.Priority
      ,R.IsDaily*DATEDIFF(DAY,ISNULL(A.Job_LastUpdate,0),GETDATE()) IsDaily
      ,R.IsWeekly*DATEDIFF(WEEK,ISNULL(A.Job_LastUpdate,0),GETDATE())*CASE WHEN DATEPART(WEEKDAY,GETDATE()) >= R.RunWeekDay THEN 1 ELSE 0 END IsWeekly
      ,R.IsMonthly*DATEDIFF(MONTH,ISNULL(A.Job_LastUpdate,0),GETDATE()) IsMonthly
      ,R.IsQuarterly*(DATEDIFF(MONTH,(SELECT QuarterStart FROM dbo.GetQrtStartEndDates(ISNULL(A.Job_LastUpdate,0),0)),EOMONTH(GETDATE()))-3) IsQuarterly
FROM adm.ReportJob R
LEFT OUTER JOIN (SELECT ReportID, MAX(Job_LastUpdate) Job_LastUpdate
				 FROM adm.ReportJobAudit
				 WHERE JobStatus = 1
				 GROUP BY ReportID) A
ON R.ReportID = A.ReportID
WHERE R.Enabled = 1)
-- This will be used to make sure the job can be re-tried only 5 times
,cte_ConsecutiveRuns AS(
SELECT ReportID,COUNT(1) AS NumberOfRuns, SUM(JobStatus) ConsecutiveRuns
FROM (SELECT ReportId
	  ,JobStatus
	  ,ROW_NUMBER() OVER(PARTITION BY ReportID ORDER BY Job_StartDate DESC) LastRuns
	  FROM adm.ReportJobAudit) RA
WHERE RA.LastRuns <= 5
GROUP BY ReportID)
-- Get Highest priority Report Job name.
SELECT TOP 1 @Job_Name = ReportJobName
FROM cte_ReportJobList L
LEFT OUTER JOIN cte_ConsecutiveRuns C
ON L.ReportId = C.ReportId
WHERE (IsDaily+IsWeekly+IsMonthly+(IsQuarterly*ISNULL(@IsDataAvailable,0)) > 0)
	AND (ISNULL(C.ConsecutiveRuns,1) > 0 OR NumberOfRuns < 5)
ORDER BY Priority;

IF @Job_Name IS NOT NULL
	EXEC msdb.dbo.sp_start_job @Job_Name = @Job_Name;

END
GO
