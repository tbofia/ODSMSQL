IF NOT EXISTS (
		SELECT object_id
		FROM sys.indexes
		WHERE object_id = OBJECT_ID('rpt.ProcessStepAudit')
			AND NAME = 'IX_ProcessStepId_CurrentCheckpoint'
		)
CREATE INDEX IX_ProcessStepId_CurrentCheckpoint 
ON rpt.ProcessStepAudit(ProcessStepId, CurrentCheckpoint DESC)
GO
