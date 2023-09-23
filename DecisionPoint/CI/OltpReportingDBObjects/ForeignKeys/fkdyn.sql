IF OBJECT_ID('rpt.FK_PostingGroupAudit_PostingGroup', 'F') IS NULL
ALTER TABLE rpt.PostingGroupAudit ADD CONSTRAINT FK_PostingGroupAudit_PostingGroup
    FOREIGN KEY (PostingGroupId)
    REFERENCES rpt.PostingGroup(PostingGroupId)
GO

IF OBJECT_ID('rpt.FK_PostingGroupAudit_DataExtractType', 'F') IS NULL
ALTER TABLE rpt.PostingGroupAudit ADD CONSTRAINT FK_PostingGroupAudit_DataExtractType
    FOREIGN KEY (DataExtractTypeId)
    REFERENCES rpt.DataExtractType(DataExtractTypeId)
GO
IF OBJECT_ID('rpt.FK_ProcessAudit_PostingGroupAudit', 'F') IS NULL
ALTER TABLE rpt.ProcessAudit ADD CONSTRAINT FK_ProcessAudit_PostingGroupAudit
    FOREIGN KEY (PostingGroupAuditId)
    REFERENCES rpt.PostingGroupAudit(PostingGroupAuditId)
GO

IF OBJECT_ID('rpt.FK_ProcessAudit_Process', 'F') IS NULL
ALTER TABLE rpt.ProcessAudit ADD CONSTRAINT FK_ProcessAudit_Process
    FOREIGN KEY (ProcessId)
    REFERENCES rpt.Process(ProcessId)
GO
IF OBJECT_ID('rpt.FK_ProcessCheckpoint_Process', 'F') IS NULL
ALTER TABLE rpt.ProcessCheckpoint ADD CONSTRAINT FK_ProcessCheckpoint_Process
    FOREIGN KEY (ProcessId)
    REFERENCES rpt.Process(ProcessId)
GO
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
