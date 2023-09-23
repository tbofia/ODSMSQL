-- Delete Audit objects that would violate foreign key referential integrity
SET NOCOUNT ON;

DELETE PSA 
FROM rpt.ProcessStepAudit PSA
LEFT OUTER JOIN rpt.ProcessStep PS
ON PSA.ProcessStepId = PS.ProcessStepId
WHERE PS.ProcessStepId IS NULL;
GO

DELETE PA
FROM rpt.ProcessAudit PA
LEFT OUTER JOIN rpt.Process P
On PA.ProcessId = P.ProcessId
WHERE P.ProcessId IS NULL;
GO

DELETE CP
FROM rpt.ProcessCheckpoint CP
LEFT OUTER JOIN rpt.Process P
On CP.ProcessId = P.ProcessId
WHERE P.ProcessId IS NULL;
GO





