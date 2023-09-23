IF OBJECT_ID('dbo.ETL_loaddurations', 'V') IS NOT NULL
DROP VIEW dbo.ETL_loaddurations
GO

CREATE VIEW dbo.ETL_loaddurations
AS
SELECT C.CustomerId
	  ,C.CustomerName
	  ,PGA.OltpPostingGroupAuditId
      ,CONVERT(VARCHAR(10),PGA.CreateDate,101) ETLLoadDate
      ,CASE WHEN COUNT(PGA.OltpPostingGroupAuditId) <> SUM(CASE WHEN PGA.Status = 'FI' THEN 1 ELSE 0 END) THEN 0 ELSE 1 END ETLCompletionStatus
      ,DATEDIFF(SS,PGA.CreateDate,PGA.LastChangeDate) AS LoadTime
		
FROM adm.PostingGroupAudit PGA
INNER JOIN adm.Customer C
ON PGA.CustomerId = C.CustomerId
LEFT OUTER JOIN adm.PostingGroupAudit PGA2
	ON PGA.CustomerId = PGA2.CustomerId
	AND PGA.OltpPostingGroupAuditId = PGA2.OltpPostingGroupAuditId
	AND PGA2.Status = 'FI'
WHERE (PGA.Status = 'FI' AND PGA2.Status = 'FI')
OR (PGA2.Status IS NULL)
GROUP By C.CustomerId
	,C.CustomerName
	,PGA.OltpPostingGroupAuditId
	,CONVERT(VARCHAR(10),PGA.CreateDate,101)
	,DATEDIFF(SS,PGA.CreateDate,PGA.LastChangeDate)


GO


