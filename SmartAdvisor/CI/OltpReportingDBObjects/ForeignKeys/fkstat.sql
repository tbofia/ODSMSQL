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
IF OBJECT_ID('rpt.FK_Process_Product', 'F') IS NULL
ALTER TABLE rpt.Process ADD CONSTRAINT FK_Process_Product
    FOREIGN KEY (ProductKey)
    REFERENCES rpt.Product(ProductKey)
GO
IF OBJECT_ID('rpt.FK_ProcessStep_Process', 'F') IS NULL
ALTER TABLE rpt.ProcessStep ADD CONSTRAINT FK_ProcessStep_Process
    FOREIGN KEY (ProcessId)
    REFERENCES rpt.Process(ProcessId)
GO
