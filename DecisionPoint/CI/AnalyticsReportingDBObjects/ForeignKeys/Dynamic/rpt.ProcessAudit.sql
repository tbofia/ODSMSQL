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
