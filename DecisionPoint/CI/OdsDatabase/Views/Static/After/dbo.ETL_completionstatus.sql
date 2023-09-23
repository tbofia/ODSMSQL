
IF OBJECT_ID('dbo.ETL_completionstatus', 'V') IS NOT NULL
DROP VIEW dbo.ETL_completionstatus
GO

CREATE VIEW dbo.ETL_completionstatus
AS
SELECT SnapshotDate AS ETLLoadDate
      ,COUNT(DiSTINCT CASE WHEN IsFullLoadCompleted = 1 THEN Customerid END) NoOfCustomersWithCompletedFullLoads
      ,COUNT(DISTINCT CASE WHEN CmpltOltpPostingGroupAuditId IS NOT NULL OR CmpltOltpPostingGroupAuditId IS NOT NULL THEN Customerid END) NoOfCustomersWithFiles
      ,SUM (CASE WHEN CmpltOltpPostingGroupAuditId IS NOT NULL OR CmpltOltpPostingGroupAuditId IS NOT NULL THEN 1 ELSE 0 END) NoOfPostingGroups
      ,SUM (CASE WHEN CmpltOltpPostingGroupAuditId IS NOT NULL THEN 1 ELSE 0 END) NoOfCompletePostingGroups
      -- When number of files available is not same as number of completed files.
	  ,CASE WHEN SUM (CASE WHEN CmpltOltpPostingGroupAuditId IS NOT NULL OR CmpltOltpPostingGroupAuditId IS NOT NULL THEN 1 ELSE 0 END) <> SUM (CASE WHEN CmpltOltpPostingGroupAuditId IS NOT NULL THEN 1 ELSE 0 END) THEN 0 
	  -- When number of customers with completed fullloads is not same as number of customers with files
			WHEN COUNT (DiSTINCT CASE WHEN IsFullLoadCompleted = 1 THEN Customerid END) > COUNT (DISTINCT CASE WHEN CmpltOltpPostingGroupAuditId IS NOT NULL OR CmpltOltpPostingGroupAuditId IS NOT NULL THEN Customerid END) THEN 2 
			ELSE 1 END ETLCompletionStatus
FROM ETL_completionstatusbaseline
GROUP BY SnapshotDate

GO

