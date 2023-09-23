IF OBJECT_ID('rpt.FK_ProcessStepAudit_ProcessStep', 'F') IS NULL
ALTER TABLE rpt.ProcessStepAudit ADD CONSTRAINT FK_ProcessStepAudit_ProcessStep
    FOREIGN KEY (ProcessStepId)
    REFERENCES rpt.ProcessStep(ProcessStepId)
GO

IF OBJECT_ID('rpt.FK_ProcessStepAudit_ProcessAudit', 'F') IS NULL
ALTER TABLE rpt.ProcessStepAudit ADD CONSTRAINT FK_ProcessStepAudit_ProcessAudit
    FOREIGN KEY (ProcessAuditId)
    REFERENCES rpt.ProcessAudit(ProcessAuditId)
GO
