IF OBJECT_ID('rpt.FK_PostingGroupProcess_Process', 'F') IS NULL
ALTER TABLE rpt.PostingGroupProcess ADD CONSTRAINT FK_PostingGroupProcess_Process 
    FOREIGN KEY (ProcessId)
    REFERENCES rpt.Process(ProcessId)
GO

IF OBJECT_ID('rpt.FK_PostingGroupProcess_PostingGroup', 'F') IS NULL
ALTER TABLE rpt.PostingGroupProcess ADD CONSTRAINT FK_PostingGroupProcess_PostingGroup 
    FOREIGN KEY (PostingGroupId)
    REFERENCES rpt.PostingGroup(PostingGroupId)
GO
