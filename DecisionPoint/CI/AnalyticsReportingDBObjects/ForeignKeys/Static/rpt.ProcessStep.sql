IF OBJECT_ID('rpt.FK_ProcessStep_Process', 'F') IS NULL
ALTER TABLE rpt.ProcessStep ADD CONSTRAINT FK_ProcessStep_Process
    FOREIGN KEY (ProcessId)
    REFERENCES rpt.Process(ProcessId)
GO
