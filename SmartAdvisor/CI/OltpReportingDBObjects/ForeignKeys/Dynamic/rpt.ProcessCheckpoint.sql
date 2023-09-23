IF OBJECT_ID('rpt.FK_ProcessCheckpoint_Process', 'F') IS NULL
ALTER TABLE rpt.ProcessCheckpoint ADD CONSTRAINT FK_ProcessCheckpoint_Process
    FOREIGN KEY (ProcessId)
    REFERENCES rpt.Process(ProcessId)
GO
