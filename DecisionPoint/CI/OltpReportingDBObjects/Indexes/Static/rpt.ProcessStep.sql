IF NOT EXISTS (
		SELECT object_id
		FROM sys.indexes
		WHERE object_id = OBJECT_ID('rpt.ProcessStep')
			AND NAME = 'UQ_ProcessId_Priority_MinAppVersion'
		)
CREATE UNIQUE INDEX UQ_ProcessId_Priority_MinAppVersion ON rpt.ProcessStep(ProcessId, Priority, MinAppVersion)
GO
