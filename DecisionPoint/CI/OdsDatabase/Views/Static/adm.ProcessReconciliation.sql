IF OBJECT_ID('adm.ProcessReconciliation', 'V') IS NOT NULL
DROP VIEW adm.ProcessReconciliation
GO

CREATE ViEW adm.ProcessReconciliation 
AS
SELECT DISTINCT PGA.CustomerId
	,PGA.CustomerName
	,P.ProcessId
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
-- Exclude tables that have irregular chnage tracking pattern : Esp_Ppo_Billing_Data_Self_Bill
AND P.ProcessId NOT IN (202)
AND P.IsSnapshot = 0
WHERE PA.TotalRecordsInSource <> PA.TotalRecordsInTarget

GO


